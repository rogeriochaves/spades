"use strict";
const { promisify } = require("util");
const exec = promisify(require("child_process").exec);
const debug = require("debug");
const debugRunning = debug("running");

const run = command => {
  debugRunning(command);
  return exec(command, { maxBuffer: 1024 * 500 });
};

module.exports = { run };
