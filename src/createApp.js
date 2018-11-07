const fs = require("fs");
const { promisify } = require("util");
const ncp = promisify(require("ncp").ncp);
const path = require("path");
const replaceInFiles = require("replace-in-files");
const exec = promisify(require("child_process").exec);

module.exports = async (name, cmd) => {
  fs.mkdirSync(name);

  const boilerplatePath = path.join(__dirname, "..", "boilerplate");
  const ignoredFiles = fs
    .readFileSync(path.join(boilerplatePath, ".gitignore.template"))
    .toString("utf-8")
    .split("\n");
  const filter = file =>
    !ignoredFiles.some(ignored => file.split("/").pop() === ignored);

  await ncp(boilerplatePath, name, { filter });

  fs.renameSync(
    path.join(name, ".gitignore.template"),
    path.join(name, ".gitignore")
  );

  if (cmd.serverless) serverlessPackage(name);

  await replaceProjectname(name);
  await initializeGit(name);

  console.log(
    "Your app is ready! Now run the following commands to get started:\n"
  );
  console.log(`  cd ${name}`);
  console.log("  npm install");
  console.log("  npm start\n");
};

function serverlessPackage(name) {
  // delete all ssr files
  fs.unlinkSync(path.join(name, "server.js"));
  fs.unlinkSync(path.join(name, "src", "index.ejs"));
  fs.unlinkSync(path.join(name, "package.json"));
  fs.unlinkSync(path.join(name, "webpack.config.js"));

  fs.renameSync(
    path.join(name, "package.static.json"),
    path.join(name, "package.json")
  );

  fs.renameSync(
    path.join(name, "webpack.config.static.js"),
    path.join(name, "webpack.config.js")
  );

  fs.renameSync(
    path.join(name, "src", "index.static.ejs"),
    path.join(name, "src", "index.ejs")
  );
}

async function replaceProjectname(name) {
  try {
    await replaceInFiles({ files: name, from: "projectname", to: name });
  } catch (error) {
    console.log("Ups, there was an error that should be impossible!");
    console.log(
      "Please open an issue on https://github.com/rogeriochaves/spades/issues"
    );
    console.error(error);
  }
}

async function initializeGit(name) {
  try {
    await exec(
      `cd ${name} && git init . && git add -A && git commit -m "Project created with Spades"`
    );
  } catch (error) {
    console.log("Skipping git initialization due to error:", error);
  }
}
