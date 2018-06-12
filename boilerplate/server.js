const webpack = require("webpack");
const middleware = require("webpack-dev-middleware");
const webpackConfig = require("./webpack.config");
const compiler = webpack({ ...webpackConfig, mode: "development" });
const express = require("express");
const app = express();

app.set("view engine", "ejs");
app.set("views", "./src");
app.use(middleware(compiler, { serverSideRender: true }));

app.use((req, res) => {
  const assetsByChunkName = res.locals.webpackStats.toJson().assetsByChunkName;
  const bundle_path = assetsByChunkName.main;

  res.render("index", { bundle_path });
});

app.listen(8080, () =>
  console.log("projectname listening on port http://localhost:8080")
);
