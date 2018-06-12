const webpack = require("webpack");
const express = require("express");
const fs = require("fs");
const { JSDOM } = require("jsdom");
const { Script } = require("vm");

const app = express();
app.set("view engine", "ejs");
app.set("views", "./src");
app.use(express.static("build"));

let webpackMiddleware;
if (process.env.NODE_ENV !== "production") {
  const webpackDevMiddleware = require("webpack-dev-middleware");
  const webpackConfig = require("./webpack.config");
  const compiler = webpack({ ...webpackConfig, mode: "development" });
  webpackMiddleware = webpackDevMiddleware(compiler, {
    serverSideRender: true,
    publicPath: "/"
  });
  app.use(webpackMiddleware);
}

app.use((req, res, next) => {
  const bundle = getBundle(res);
  const fullUrl = `${req.protocol}://${req.get("host")}${req.originalUrl}`;

  renderElmApp(bundle.file, fullUrl)
    .then(renderedHtml => {
      res.render("index", { bundlePath: bundle.path, renderedHtml });
    })
    .catch(next);
});

const getBundle = res => {
  let path;
  let file;
  if (process.env.NODE_ENV === "production") {
    path = require("./build/stats.json").assetsByChunkName.main;
    file = fs.readFileSync(`./build/${path}`, "utf8");
  } else {
    path = res.locals.webpackStats.toJson().assetsByChunkName.main;
    file = webpackMiddleware.fileSystem.readFileSync(
      `/${process.cwd()}/build/${path}`,
      "utf8"
    );
  }
  return { path, file };
};

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
