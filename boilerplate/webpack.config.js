const config = isDev => ({
  entry: "./src/index.js",
  output: {
    path: `${__dirname}/build`,
    filename: "[name].[hash].js"
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
              forceWatch: isDev,
              debug: isDev
            }
          }
        ]
      }
    ]
  }
});

module.exports = (_, argv) => config(argv.mode !== "production");
