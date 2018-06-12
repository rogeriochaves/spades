const webpack = require("webpack");
const webpackDevMiddleware = require("webpack-dev-middleware");
const webpackConfig = require("./webpack.config");
const express = require("express");
const { JSDOM } = require("jsdom");
const { Script } = require("vm");

const app = express();
const compiler = webpack({ ...webpackConfig, mode: "production" });
const webpackMiddleware = webpackDevMiddleware(compiler, {
  serverSideRender: true
});

app.set("view engine", "ejs");
app.set("views", "./src");
app.use(webpackMiddleware);

app.use((req, res, next) => {
  const assetsByChunkName = res.locals.webpackStats.toJson().assetsByChunkName;
  const bundlePath = assetsByChunkName.main;
  const bundleFile = webpackMiddleware.fileSystem.readFileSync(
    `/${process.cwd()}/build/${bundlePath}`,
    "utf8"
  );
  const fullUrl = `${req.protocol}://${req.get("host")}${req.originalUrl}`;
  console.log("fullUrl", fullUrl);

  renderElmApp(bundleFile, fullUrl)
    .then(renderedHtml => {
      res.render("index", { bundlePath, renderedHtml });
    })
    .catch(next);
});

const renderElmApp = (bundleFile, url) =>
  new Promise((resolve, reject) => {
    const dom = new JSDOM(`<!DOCTYPE html><html><body></body></html>`, {
      url,
      runScripts: "outside-only"
    });
    try {
      dom.runVMScript(new Script(bundleFile));
    } catch (err) {
      reject(err);
    }

    setTimeout(() => {
      resolve(dom.window.document.body.innerHTML);
    }, 1);
  });

app.listen(8080, () =>
  console.log("projectname listening on port http://localhost:8080")
);
