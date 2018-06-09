var app = Elm.Main.fullscreen(window.flags);

app.ports.onSuccess.subscribe(window.onSuccess);
app.ports.onError.subscribe(window.onError);
