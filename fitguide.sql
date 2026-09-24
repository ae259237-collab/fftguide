--
-- PostgreSQL database dump
--

\restrict eKbdZX3G3XsSCLorolDt6weAJFjwcPrtLG0mGFhmcLegJedkUPwjr69qwRnpqLs

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-09-24 12:57:45

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16396)
-- Name: Authorization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Authorization" (
    "ID_Authorization" integer NOT NULL,
    "Login" character varying(50) NOT NULL,
    "Password" character varying(50) NOT NULL
);


ALTER TABLE public."Authorization" OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16436)
-- Name: Payment_method; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Payment_method" (
    "ID_Payment_method" integer NOT NULL,
    "Name" character varying(150) NOT NULL
);


ALTER TABLE public."Payment_method" OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16389)
-- Name: Position; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Position" (
    "ID_Position" integer NOT NULL,
    "Name" character varying(150) NOT NULL
);


ALTER TABLE public."Position" OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16443)
-- Name: Status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Status" (
    "ID_Status" integer NOT NULL,
    "Name" character varying(150) NOT NULL
);


ALTER TABLE public."Status" OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16450)
-- Name: Training_Request; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Training_Request" (
    "ID_Training_Request" integer NOT NULL,
    "Training_date" date NOT NULL,
    "ID_User" integer NOT NULL,
    "ID_Status" integer NOT NULL,
    "ID_Workout" integer NOT NULL,
    "ID_Payment_method" integer NOT NULL
);


ALTER TABLE public."Training_Request" OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16404)
-- Name: User; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."User" (
    "ID_User" integer NOT NULL,
    "LastName" character varying(250) NOT NULL,
    "FirstName" character varying(250) NOT NULL,
    "MiddleName" character varying(250),
    "DataOfBirth" date,
    "Phone" character varying(20) NOT NULL,
    "Email" character varying(250),
    "ID_Position" integer NOT NULL,
    "ID_Authorization" integer NOT NULL,
    "Blocked" boolean NOT NULL
);


ALTER TABLE public."User" OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16428)
-- Name: Workout; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Workout" (
    "ID_Workout" integer NOT NULL,
    "Workout_code" character varying(50) NOT NULL,
    "Name" character varying(250) NOT NULL
);


ALTER TABLE public."Workout" OWNER TO postgres;

--
-- TOC entry 5049 (class 0 OID 16396)
-- Dependencies: 220
-- Data for Name: Authorization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Authorization" ("ID_Authorization", "Login", "Password") FROM stdin;
1	client1	client123
2	client2	client123
3	client3	client123
4	client4	client123
5	admin	admin123
6	alex	bbwsit
\.


--
-- TOC entry 5052 (class 0 OID 16436)
-- Dependencies: 223
-- Data for Name: Payment_method; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Payment_method" ("ID_Payment_method", "Name") FROM stdin;
1	Банковская карта
2	СБП
3	Наличные
4	Банковский перевод
5	Онлайн-оплата
\.


--
-- TOC entry 5048 (class 0 OID 16389)
-- Dependencies: 219
-- Data for Name: Position; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Position" ("ID_Position", "Name") FROM stdin;
1	Клиент
2	Администратор
\.


--
-- TOC entry 5053 (class 0 OID 16443)
-- Dependencies: 224
-- Data for Name: Status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Status" ("ID_Status", "Name") FROM stdin;
1	Новая
2	В работе
3	Выполнен
4	Отменен
5	Ожидает оплаты
\.


--
-- TOC entry 5054 (class 0 OID 16450)
-- Dependencies: 225
-- Data for Name: Training_Request; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Training_Request" ("ID_Training_Request", "Training_date", "ID_User", "ID_Status", "ID_Workout", "ID_Payment_method") FROM stdin;
1	2026-10-01	1	1	1	1
2	2026-10-03	2	2	2	2
3	2026-10-05	3	1	3	3
4	2026-10-07	4	3	4	5
5	2026-10-10	1	4	5	4
6	2026-01-10	1	1	1	2
\.


--
-- TOC entry 5050 (class 0 OID 16404)
-- Dependencies: 221
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."User" ("ID_User", "LastName", "FirstName", "MiddleName", "DataOfBirth", "Phone", "Email", "ID_Position", "ID_Authorization", "Blocked") FROM stdin;
1	Иванова	Анна	Сергеевна	2005-03-15	+79990000001	client1@example.com	1	1	f
2	Петрова	Мария	Алексеевна	2004-07-21	+79990000002	client2@example.com	1	2	f
3	Сидорова	Ольга	Игоревна	2003-11-08	+79990000003	client3@example.com	1	3	f
4	Кузнецова	Алина	Владимировна	2002-05-30	+79990000004	client4@example.com	1	4	f
5	Смирнова	Елена	Александровна	1999-01-19	+79990000005	admin@example.com	2	5	f
6	Егорова	Александра	Владимировна	\N	89605449365	ae259237@gmail.com	1	6	f
\.


--
-- TOC entry 5051 (class 0 OID 16428)
-- Dependencies: 222
-- Data for Name: Workout; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Workout" ("ID_Workout", "Workout_code", "Name") FROM stdin;
1	W001	Силовая тренировка
2	W002	Кардио
3	W003	Функциональная тренировка
4	W004	Растяжка
5	W005	Тренировка на пресс
\.


--
-- TOC entry 4882 (class 2606 OID 16482)
-- Name: Authorization Authorization_Login_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Authorization"
    ADD CONSTRAINT "Authorization_Login_unique" UNIQUE ("Login");


--
-- TOC entry 4884 (class 2606 OID 16403)
-- Name: Authorization Authorization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Authorization"
    ADD CONSTRAINT "Authorization_pkey" PRIMARY KEY ("ID_Authorization");


--
-- TOC entry 4890 (class 2606 OID 16442)
-- Name: Payment_method Payment_method_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment_method"
    ADD CONSTRAINT "Payment_method_pkey" PRIMARY KEY ("ID_Payment_method");


--
-- TOC entry 4880 (class 2606 OID 16395)
-- Name: Position Position_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Position"
    ADD CONSTRAINT "Position_pkey" PRIMARY KEY ("ID_Position");


--
-- TOC entry 4892 (class 2606 OID 16449)
-- Name: Status Status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Status"
    ADD CONSTRAINT "Status_pkey" PRIMARY KEY ("ID_Status");


--
-- TOC entry 4894 (class 2606 OID 16460)
-- Name: Training_Request Training_Request_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Training_Request"
    ADD CONSTRAINT "Training_Request_pkey" PRIMARY KEY ("ID_Training_Request");


--
-- TOC entry 4886 (class 2606 OID 16417)
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY ("ID_User");


--
-- TOC entry 4888 (class 2606 OID 16435)
-- Name: Workout Workout_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Workout"
    ADD CONSTRAINT "Workout_pkey" PRIMARY KEY ("ID_Workout");


--
-- TOC entry 4897 (class 2606 OID 16476)
-- Name: Training_Request Training_Request_Payment_method_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Training_Request"
    ADD CONSTRAINT "Training_Request_Payment_method_fkey" FOREIGN KEY ("ID_Payment_method") REFERENCES public."Payment_method"("ID_Payment_method");


--
-- TOC entry 4898 (class 2606 OID 16466)
-- Name: Training_Request Training_Request_Status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Training_Request"
    ADD CONSTRAINT "Training_Request_Status_fkey" FOREIGN KEY ("ID_Status") REFERENCES public."Status"("ID_Status");


--
-- TOC entry 4899 (class 2606 OID 16461)
-- Name: Training_Request Training_Request_User_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Training_Request"
    ADD CONSTRAINT "Training_Request_User_fkey" FOREIGN KEY ("ID_User") REFERENCES public."User"("ID_User");


--
-- TOC entry 4900 (class 2606 OID 16471)
-- Name: Training_Request Training_Request_Workout_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Training_Request"
    ADD CONSTRAINT "Training_Request_Workout_fkey" FOREIGN KEY ("ID_Workout") REFERENCES public."Workout"("ID_Workout");


--
-- TOC entry 4895 (class 2606 OID 16418)
-- Name: User User_Login_Authorization_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_Login_Authorization_fkey" FOREIGN KEY ("ID_Authorization") REFERENCES public."Authorization"("ID_Authorization");


--
-- TOC entry 4896 (class 2606 OID 16423)
-- Name: User User_Position_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_Position_fkey" FOREIGN KEY ("ID_Position") REFERENCES public."Position"("ID_Position");


-- Completed on 2026-09-24 12:57:46

--
-- PostgreSQL database dump complete
--

\unrestrict eKbdZX3G3XsSCLorolDt6weAJFjwcPrtLG0mGFhmcLegJedkUPwjr69qwRnpqLs

