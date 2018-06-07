import { JSDOM } from "jsdom";
import { Script } from "vm";
import Elm from "raw-loader!./Main.elm";
import ElmInterface from "raw-loader!./elm-interface";

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
