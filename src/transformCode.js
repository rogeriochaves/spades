const { JSDOM } = require("jsdom");
const { Script } = require("vm");
const fs = require("fs");
const { execSync } = require("child_process");
const ejs = require("ejs");
const Elm = fs.readFileSync(`${__dirname}/../out/elm.js`);
const ElmInterface = fs.readFileSync(`${__dirname}/elmInterface.js`);

const namedTransformation = (filePath, transformer) => name =>
  executeTransformation({
    transformer,
    code: fs.readFileSync(filePath).toString("utf-8"),
    args: { name }
  })
    .then(content => {
      fs.writeFileSync(filePath, content);
      try {
        execSync(`elm-format ${filePath} --yes`);
      } catch (err) {
        throw err.stderr.toString("utf-8");
      }
      console.log(`Updated ${filePath} file`);
    })
    .catch(err => console.error(err));

const executeTransformation = flags =>
  new Promise((resolve, reject) => {
    const dom = new JSDOM(`<!DOCTYPE html><html><head><body></body></html>`, {
      runScripts: "outside-only"
    });

    dom.window.flags = flags;
    dom.window.onSuccess = resolve;
    dom.window.onError = reject;

    const script = new Script(`
  ${Elm};
  ${ElmInterface};
`);
    dom.runVMScript(script);
  });

const copyTemplate = (templateName, destination, options) => {
  const templatePath = `${__dirname}/templates/${templateName}`;
  const templateFile = fs.readFileSync(templatePath).toString("utf-8");
  const compiledContent = ejs.render(templateFile, options);
  fs.writeFileSync(destination, compiledContent);
};

const addRoute = namedTransformation("src/Router/Routes.elm", "ADD_ROUTE");
const addComponentView = namedTransformation(
  "src/View.elm",
  "ADD_COMPONENT_VIEW"
);
const addComponentTypes = namedTransformation(
  "src/Types.elm",
  "ADD_COMPONENT_TYPES"
);
const addComponentUpdate = namedTransformation(
  "src/Update.elm",
  "ADD_COMPONENT_UPDATE"
);
const addComponent = name => {
  fs.mkdirSync(`src/${name}`);
  copyTemplate("Types.ejs.elm", `src/${name}/Types.elm`, { name });
  copyTemplate("Update.ejs.elm", `src/${name}/Update.elm`, { name });
  copyTemplate("View.ejs.elm", `src/${name}/View.elm`, { name });
  console.log(`Created src/${name} component`);

  return addRoute(name)
    .then(() => addComponentTypes(name))
    .then(() => addComponentUpdate(name))
    .then(() => addComponentView(name));
};

module.exports = {
  addRoute,
  addComponent,
  addComponentView,
  addComponentTypes,
  addComponentUpdate
};
