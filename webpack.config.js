const HtmlWebpackPlugin = require("html-webpack-plugin");

const config = (env, argv) => ({
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
        use:
          argv.mode === "production"
            ? ["elm-webpack-loader"]
            : ["elm-webpack-loader?debug=true"]
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "src/index.ejs"
    })
  ]
});

module.exports = config;
