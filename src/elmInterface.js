var app = Elm.Main.init({ flags: window.flags, node: document.body });

app.ports.onSuccess.subscribe(window.onSuccess);
app.ports.onError.subscribe(window.onError);
