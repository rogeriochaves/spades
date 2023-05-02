const config = isDev => ({
  entry: "./src/index.js",
  output: {
    path: `${__dirname}/build`,
    filename: "[name].[fullhash].js"
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          {
            loader: "elm-webpack-loader",
            options: {
              debug: isDev
            }
          }
        ]
      }
    ]
  }
});

module.exports = (_, argv) => config(argv.mode !== "production");
