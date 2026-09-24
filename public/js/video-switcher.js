document.addEventListener("DOMContentLoaded", function () {
  const video = document.getElementById("fitguideVideo");
  const source = document.getElementById("fitguideVideoSource");
  const cards = document.querySelectorAll(".vhs-card");

  if (!video || !source || !cards.length) {
    return;
  }

  video.muted = true;
  video.playsInline = true;

  cards.forEach(function (card) {
    card.addEventListener("click", function () {
      const file = card.getAttribute("data-video");

      if (!file) {
        return;
      }

      cards.forEach(function (item) {
        item.classList.remove("is-active");
      });
      card.classList.add("is-active");

      video.pause();

      // Use the video element itself as the source. This avoids browser cache
      // issues that can happen when only the nested <source> is changed.
      source.src = file;
      video.src = file;
      video.load();

      const startVideo = function () {
        video.removeEventListener("loadeddata", startVideo);
        video.currentTime = 0;

        const playRequest = video.play();
        if (playRequest && typeof playRequest.catch === "function") {
          playRequest.catch(function () {});
        }
      };

      video.addEventListener("loadeddata", startVideo);
    });
  });
});
