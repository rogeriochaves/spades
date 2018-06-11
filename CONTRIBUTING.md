# Contributing

Contributions are always welcome, no matter how large or small.

## Running the project

After clonning the codebase, you can install the dependencies, build it, and run it locally:

```
npm install
npm run build
./bin/elm-generate somecommand
```

You can also install the npm dependency globally from the local repo:

```
npm -g install .
```

## Testing

Run all the tests with:

```
npm run test
```

You may also run `test:unit` and `test:functional` separetly.

The unit tests test individual functions and files, while the functional tests are more end-to-end: it installs the Elm on Rails CLI and simulates a user creating a project and executing some commands.

## Architecture

Elm on Rails is basically split in three parts: the **boilerplate**, the **templates** and the **transformers**.

The **boilerplate** is the base application that is generated with the `elm generate app` command, it is fully-working a standalone aplication, which means that you can run it separelety if you wish to make changes to it.

To run the boilerplate:

```
cd boilerplate
npm install
npm start
```

The **templates** are .ejs template files that are copied into the user's project when it needs new file, with placeholders to some variables such as generated the component name, they live under `src/templates`.

The **transformers** are responsible for updating existing files, such as adding a new route to the routes file. This is a much complex task as we have to be sure to not generate invalid Elm code as a result.

For creating the transformers we use the [elm-syntax](http://package.elm-lang.org/packages/stil4m/elm-syntax) library, which decodes Elm codes into an [AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree) where we transform the code, and the encodes it back into valid Elm code.

Everything is then coupled together by the CLI in the `src/index.js` file by using the [commander.js](https://github.com/tj/commander.js) library.
