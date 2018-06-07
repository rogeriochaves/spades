var app = Elm.Main.fullscreen();

setTimeout(function() {
  window.onMessage(document.body.textContent);
}, 0);
