const { JSDOM } = require("jsdom");
const { Script } = require("vm");
const fs = require("fs");
const Elm = fs.readFileSync(`${__dirname}/../out/elm.js`);
const ElmInterface = fs.readFileSync(`${__dirname}/elm-interface.js`);

const dom = new JSDOM(`<!DOCTYPE html><html><head><body></body></html>`, {
  runScripts: "outside-only"
});

dom.window.onMessage = msg => {
  console.log(msg);
};

const script = new Script(`
  ${Elm};
  ${ElmInterface};
`);
dom.runVMScript(script);
