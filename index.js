const express = require("express");
const pg = require("pg");
const session = require("express-session");
const exphbs = require("express-handlebars");
const path = require("path");

const app = express();

// ================================
// ПОДКЛЮЧЕНИЕ К POSTGRESQL
// ================================

const pool = new pg.Pool({
  user: "postgres",
  host: "localhost",
  password: process.env.DB_PASSWORD,
  database: "fitguide",
  port: 5432,
});

// ================================
// НАСТРОЙКА SESSION
// ================================

app.use(
  session({
    secret: "fitguide-secret",
    resave: false,
    saveUninitialized: false,
  }),
);

app.use((req, res, next) => {
  res.locals.userId = req.session.userId || null;
  res.locals.role = req.session.role || null;
  res.locals.isAdmin = req.session.role === "Администратор";

  next();
});

// ================================
// ПАРСЕРЫ ДАННЫХ ФОРМ
// ================================

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// ================================
// HANDLEBARS
// ================================

app.engine(
  "hbs",
  exphbs.engine({
    extname: "hbs",
    defaultLayout: "main",
    layoutsDir: path.join(__dirname, "views", "layouts"),
    partialsDir: path.join(__dirname, "views", "partials"),
  }),
);

app.set("view engine", "hbs");
app.set("views", path.join(__dirname, "views"));

// ================================
// СТАТИЧЕСКИЕ ФАЙЛЫ
// ================================

app.use(express.static(path.join(__dirname, "public")));

// ================================
// ПРОВЕРКА ПОДКЛЮЧЕНИЯ К БД
// ================================

app.get("/db-test", async (req, res) => {
  try {
    const result = await pool.query("SELECT NOW()");

    res.send(`
            <h1>PostgreSQL подключён!</h1>
            <p>Время сервера БД: ${result.rows[0].now}</p>
        `);
  } catch (error) {
    console.error(error);
    res.status(500).send("Ошибка подключения к PostgreSQL");
  }
});
app.get("/", (req, res) => {
  res.render("home");
});

app.get("/login", (req, res) => {
  res.render("auth");
});
app.get("/register", (req, res) => {
  res.render("register");
});

app.post("/register", async (req, res) => {
  const { lastName, firstName, middleName, phone, email, login, password } =
    req.body;

  try {
    // Проверяем, существует ли такой логин
    const loginCheck = await pool.query(
      `
      SELECT "ID_Authorization"
      FROM public."Authorization"
      WHERE "Login" = $1
      `,
      [login],
    );

    if (loginCheck.rows.length > 0) {
      return res
        .status(400)
        .send("Пользователь с таким логином уже существует");
    }

    // Начинаем транзакцию
    await pool.query("BEGIN");

    // Получаем следующий ID для Authorization
    const authorizationIdResult = await pool.query(`
      SELECT COALESCE(MAX("ID_Authorization"), 0) + 1 AS "next_id"
      FROM public."Authorization"
    `);

    const authorizationId = authorizationIdResult.rows[0].next_id;

    // Создаём данные авторизации
    await pool.query(
      `
      INSERT INTO public."Authorization"
      ("ID_Authorization", "Login", "Password")
      VALUES ($1, $2, $3)
      `,
      [authorizationId, login, password],
    );

    // Получаем следующий ID пользователя
    const userIdResult = await pool.query(`
      SELECT COALESCE(MAX("ID_User"), 0) + 1 AS "next_id"
      FROM public."User"
    `);

    const userId = userIdResult.rows[0].next_id;

    // Создаём пользователя.
    // ID_Position = 1 — Клиент.
    await pool.query(
      `
      INSERT INTO public."User"
      (
        "ID_User",
        "LastName",
        "FirstName",
        "MiddleName",
        "Phone",
        "Email",
        "ID_Position",
        "ID_Authorization",
        "Blocked"
      )
      VALUES ($1, $2, $3, $4, $5, $6, 1, $7, false)
      `,
      [
        userId,
        lastName,
        firstName,
        middleName || null,
        phone,
        email || null,
        authorizationId,
      ],
    );

    await pool.query("COMMIT");

    res.redirect("/login");
  } catch (error) {
    await pool.query("ROLLBACK");

    console.error(error);
    res.status(500).send("Ошибка регистрации");
  }
});

app.post("/login", async (req, res) => {
  console.log("LOGIN BODY:", req.body);
  const { login, password } = req.body;

  try {
    const result = await pool.query(
      `
      SELECT
        u."ID_User",
        u."Blocked",
        p."Name" AS "RoleName"
      FROM public."User" u
      JOIN public."Authorization" a
        ON u."ID_Authorization" = a."ID_Authorization"
      JOIN public."Position" p
        ON u."ID_Position" = p."ID_Position"
      WHERE a."Login" = $1
        AND a."Password" = $2
      `,
      [login, password],
    );

    if (result.rows.length === 0) {
      return res.status(401).send("Неверный логин или пароль");
    }

    const user = result.rows[0];

    if (user.Blocked) {
      return res.status(403).send("Пользователь заблокирован");
    }

    // Записываем пользователя в сессию
    req.session.userId = user.ID_User;
    req.session.role = user.RoleName;

    if (user.RoleName === "Администратор") {
      return res.redirect("/admin");
    }

    res.redirect("/cabinet");
  } catch (error) {
    console.error(error);
    res.status(500).send("Ошибка авторизации");
  }
});

app.get("/logout", (req, res) => {
  req.session.destroy((error) => {
    if (error) {
      console.error(error);
      return res.status(500).send("Ошибка выхода из системы");
    }

    res.redirect("/login");
  });
});

app.get("/cabinet", async (req, res) => {
  if (!req.session.userId) {
    return res.redirect("/login");
  }

  try {
    const result = await pool.query(
      `
      SELECT
        tr."ID_Training_Request",
        tr."Training_date",
        w."Name" AS "WorkoutName",
        pm."Name" AS "PaymentName",
        s."Name" AS "StatusName"
      FROM public."Training_Request" tr

      JOIN public."Workout" w
        ON tr."ID_Workout" = w."ID_Workout"

      JOIN public."Payment_method" pm
        ON tr."ID_Payment_method" = pm."ID_Payment_method"

      JOIN public."Status" s
        ON tr."ID_Status" = s."ID_Status"

      WHERE tr."ID_User" = $1

      ORDER BY tr."Training_date" DESC
      `,
      [req.session.userId],
    );

    res.render("cabinet", {
      requests: result.rows,
    });
  } catch (error) {
    console.error(error);
    res.status(500).send("Ошибка загрузки личного кабинета");
  }
});

app.get("/admin", async (req, res) => {
  if (req.session.role !== "Администратор") {
    return res.status(403).send("Доступ запрещён");
  }

  try {
    const requestsResult = await pool.query(`
      SELECT
        tr."ID_Training_Request",
        TO_CHAR(tr."Training_date", 'DD.MM.YYYY') AS "Training_date",
        u."LastName",
        u."FirstName",
        w."Name" AS "WorkoutName",
        pm."Name" AS "PaymentName",
        s."Name" AS "StatusName",
        tr."ID_Status"
      FROM public."Training_Request" tr

      JOIN public."User" u
        ON tr."ID_User" = u."ID_User"

      JOIN public."Workout" w
        ON tr."ID_Workout" = w."ID_Workout"

      JOIN public."Payment_method" pm
        ON tr."ID_Payment_method" = pm."ID_Payment_method"

      JOIN public."Status" s
        ON tr."ID_Status" = s."ID_Status"

      ORDER BY tr."Training_date" DESC
    `);

    const statusesResult = await pool.query(`
      SELECT
        "ID_Status",
        "Name"
      FROM public."Status"
      ORDER BY "ID_Status"
    `);

    const requests = requestsResult.rows.map((request) => ({
      ...request,

      statuses: statusesResult.rows.map((status) => ({
        ...status,
        IsCurrent: Number(status.ID_Status) === Number(request.ID_Status),
      })),
    }));

    res.render("admin", {
      requests,
    });
  } catch (error) {
    console.error(error);
    res.status(500).send("Ошибка загрузки заявок");
  }
});

app.post("/admin/status", async (req, res) => {
  if (req.session.role !== "Администратор") {
    return res.status(403).send("Доступ запрещён");
  }

  const requestId = Number(req.body.ID_Training_Request);
  const statusId = Number(req.body.ID_Status);

  if (!Number.isInteger(requestId) || !Number.isInteger(statusId)) {
    return res.status(400).send("Некорректные данные");
  }

  try {
    await pool.query(
      `
      UPDATE public."Training_Request"
      SET "ID_Status" = $1
      WHERE "ID_Training_Request" = $2
      `,
      [statusId, requestId],
    );

    res.redirect("/admin");
  } catch (error) {
    console.error(error);
    res.status(500).send("Ошибка изменения статуса");
  }
});

app.get("/workouts", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        "ID_Workout",
        "Workout_code",
        "Name"
      FROM public."Workout"
      ORDER BY "ID_Workout"
    `);

    res.render("workouts", {
      workouts: result.rows,
    });
  } catch (error) {
    console.error(error);
    res.status(500).send("Ошибка загрузки тренировок");
  }
});

app.get("/application", async (req, res) => {
  // Заявку может создавать только авторизованный пользователь
  if (!req.session.userId) {
    return res.redirect("/login");
  }

  try {
    const workoutsResult = await pool.query(`
      SELECT
        "ID_Workout",
        "Name"
      FROM public."Workout"
      ORDER BY "ID_Workout"
    `);

    const paymentResult = await pool.query(`
      SELECT
        "ID_Payment_method",
        "Name"
      FROM public."Payment_method"
      ORDER BY "ID_Payment_method"
    `);

    res.render("application", {
      workouts: workoutsResult.rows,
      paymentMethods: paymentResult.rows,
    });
  } catch (error) {
    console.error(error);
    res.status(500).send("Ошибка загрузки формы заявки");
  }
});

app.post("/application", async (req, res) => {
  if (!req.session.userId) {
    return res.redirect("/login");
  }

  const { Training_date, ID_Workout, ID_Payment_method } = req.body;

  try {
    const result = await pool.query(`
      SELECT COALESCE(MAX("ID_Training_Request"), 0) + 1 AS "next_id"
      FROM public."Training_Request"
    `);

    const requestId = result.rows[0].next_id;

    await pool.query(
      `
      INSERT INTO public."Training_Request"
      (
        "ID_Training_Request",
        "Training_date",
        "ID_User",
        "ID_Status",
        "ID_Workout",
        "ID_Payment_method"
      )
      VALUES ($1, $2, $3, 1, $4, $5)
      `,
      [
        requestId,
        Training_date,
        req.session.userId,
        ID_Workout,
        ID_Payment_method,
      ],
    );

    res.redirect("/cabinet");
  } catch (error) {
    console.error(error);
    res.status(500).send("Ошибка создания заявки");
  }
});

// ================================
// ЗАПУСК СЕРВЕРА
// ================================

const PORT = 3000;

app.listen(PORT, () => {
  console.log(`FitGuide запущен: http://localhost:${PORT}`);
});
