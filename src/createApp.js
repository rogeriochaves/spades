const fs = require("fs");
const { promisify } = require("util");
const ncp = promisify(require("ncp").ncp);
const path = require("path");

module.exports = name => {
  fs.mkdirSync(name);

  const boilerplatePath = path.join(__dirname, "..", "boilerplate");
  const ignoredFiles = fs
    .readFileSync(path.join(boilerplatePath, ".gitignore.template"))
    .toString("utf-8")
    .split("\n");
  const filter = file =>
    !ignoredFiles.some(ignored => file.split("/").pop() === ignored);

  ncp(boilerplatePath, name, { filter }).then(() => {
    fs.renameSync(
      path.join(name, ".gitignore.template"),
      path.join(name, ".gitignore")
    );
    console.log(
      "Your app is ready! Now run the following commands to get started:\n"
    );
    console.log(`  cd ${name}`);
    console.log("  npm install");
    console.log("  npm start\n");
  });
};
