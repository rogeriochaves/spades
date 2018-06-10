# Getting Started

```
npm -g install git+https://github.com/rogeriochaves/elm-on-rails.git
elm generate app MyProject
```

# Generators

## Add new component

```
elm generate component Search
```

This is the coolest generator, it will create a Search
component under `src/`, update the main Model, Msg, Update, View and Routes for it

## Add new route

```
elm generate route Contact
```

This will create a new Page type, route parser and route toPath case on the `src/Router/Routes.elm` file

# Features

- Elm 0.19
- Architecture ready to grow into a bigger Elm app [(read more)](https://medium.com/@_rchaves_/structured-todomvc-example-with-elm-a68d87cd38da)
- Routing and Navigation
- Uses style-elements instead of html/css
- Ready for development with webpack
- RemoteData for better handling of http request
- elm-return for better composition of update functions
