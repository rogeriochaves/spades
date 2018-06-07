const config = {
  entry: "./src/index.js",
  target: "node",
  output: {
    path: `${__dirname}/bin`,
    filename: "generate"
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: ["elm-webpack-loader"]
      }
    ]
  }
};

module.exports = config;
