# Spades

[Spades](https://www.google.com/search?tbm=isch&q=tree%20spade&tbs=imgo:1) is a framework for Elm that helps you quickly start a Single Page Application (SPA) ready to the real world, with an opinionated structure that allows your app to grow easily and well organized.

It has a CLI generating all the necessary Elm boilerplate when adding new components to your application.

## Getting Started

```
npm -g install git+https://github.com/rogeriochaves/spades.git
elm-generate app MyProject
```

## Generators

### Add new component

```
elm-generate component Search
```

This is the coolest generator, it will create a Search
component under `src/`, update the main Model, Msg, Update, View and Routes for it

### Add new route

```
elm-generate route Contact
```

This will create a new Page type, route parser and route toPath case on the `src/Router/Routes.elm` file

# Demo

![spades demo](https://user-images.githubusercontent.com/792201/41208764-e2aa697e-6cfc-11e8-96ac-15750f08f8fb.gif)

# Advantages

## Does Elm need a framework?

Mostly not, at least much less than other programming languages, because Elm is already very focused on being the best language for frontend web development, has an [enforced architecture](https://guide.elm-lang.org/architecture/) and a lot of batteries included.

However, it is still a language, not a framework, therefore it can't define somethings such as how you organize your files, how you scale the architecture, how you deploy your app, which libraries to use, among other things which are usually a source of concern to beginners.

With time, it is possible that more and more things are implemented on the language and removed from this framework, leaving maybe just the initial boilerplate and the code generators.

## Spades Architecture

Just like all other Elm apps, Spades follows [The Elm Architecture](https://guide.elm-lang.org/architecture/), this architecture basically dictates all the state flow within Elm, but still allows multiple organizations as your app grows.

Spades then follows an organization with domain focus, similar to what is described on [this blogpost](https://medium.com/@_rchaves_/structured-todomvc-example-with-elm-a68d87cd38da).

Another important thing in a real-world Elm app is a solution for parent-child communication, for that part, Spades uses the NoMap pattern described on [this other blogpost](https://medium.com/@_rchaves_/child-parent-communication-in-elm-outmsg-vs-translator-vs-nomap-patterns-f51b2a25ecb1).

## Code Generators

Some people find Elm code very verbose, and that the architecture needs too much boilerplate to work. This is the intentional trade-off that the Elm Language choose to leave the language as simple, readable and explicit as possible.

To have the readability benefits, without the verbosity pain, Spades comes with a CLI to help generate code.

## Server-Side Rendering

Elm apps are usually rendered on the client, but Spades already come with a simple [express](https://expressjs.com/) server that renders the Elm app before sending the HTML to the client, improving performance for the user and [SEO](https://en.wikipedia.org/wiki/Search_engine_optimization).

Read more: https://medium.com/walmartlabs/the-benefits-of-server-side-rendering-over-client-side-rendering-5d07ff2cefe8

You can disable this option using the `--serverless` flag while creating your project:

```
elm-generate app MyProject --serverless
```

## The best layout system you will ever use

Thanks to Elm awesome type system and abstraction of the HTML the community could see things more clearly, and came up with a better way of layouting: elm-ui

We recommend watching this talk by Matthew Griffith, the creator of elm-ui, to understant how it works (elm-ui was still called style-elements back then):

https://www.youtube.com/watch?v=NYb2GDWMIm0

Spades comes with elm-ui by default, and although you can remove it and use the standard html library, we really recommend you to give it a shot, you won't regret!

(elm-ui was previously called style-elements, check out what changed [here](https://github.com/mdgriffith/elm-ui/blob/master/CHANGES-FROM-STYLE-ELEMENTS.md))

## Other Batteries Included

Aside from the advantaged mentioned above, Spades also comes with:

- Ready for Elm 0.19
- [elm-test](https://package.elm-lang.org/packages/elm-explorations/test)
- [Routing and Navigation](https://www.elm-tutorial.org/en/07-routing/cover.html)
- [Webpack](https://webpack.js.org/) for better development experience and optimized build
- [RemoteData](http://package.elm-lang.org/packages/krisajenkins/remotedata/latest/RemoteData) for better handling of http request
- [elm-return](http://package.elm-lang.org/packages/Fresheyeball/elm-return/latest) for better composition of update functions (learn more: https://elmtown.audio/a3e2133b after 38 min)

# Contributing

Just by using the framework and giving feedbacks you'll be helping a lot! You can give suggestions or report bugs on the [issues page](https://github.com/rogeriochaves/spades/issues).

If you want to contribute with Spades development, take a look on the [existing issues](https://github.com/rogeriochaves/spades/issues) and read the [CONTRIBUTING.md](CONTRIBUTING.md) file.
