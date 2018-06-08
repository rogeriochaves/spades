const { JSDOM } = require("jsdom");
const { Script } = require("vm");
const fs = require("fs");
const { execSync } = require("child_process");
const Elm = fs.readFileSync(`${__dirname}/../out/elm.js`);
const ElmInterface = fs.readFileSync(`${__dirname}/elmInterface.js`);

module.exports = () => {
  const dom = new JSDOM(`<!DOCTYPE html><html><head><body></body></html>`, {
    runScripts: "outside-only"
  });

  dom.window.flags = {
    code: fs.readFileSync("src/Router/Routes.elm").toString("utf-8")
  };

  dom.window.writeFile = content => {
    fs.writeFileSync("src/Router/Routes.elm", content);
    execSync("elm-format src/Router/Routes.elm --yes");
    console.log("Done!");
  };

  dom.window.onError = err => {
    console.error(err);
  };

  const script = new Script(`
  ${Elm};
  ${ElmInterface};
`);
  dom.runVMScript(script);
};
