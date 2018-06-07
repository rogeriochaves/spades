var app = Elm.Main.fullscreen(window.flags);

app.ports.writeFile.subscribe(window.writeFile);
app.ports.onError.subscribe(window.onError);
