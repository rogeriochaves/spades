var app = Elm.Main.fullscreen(window.flags);

app.ports.output.subscribe(function(content) {
  window.onMessage(content);
});
