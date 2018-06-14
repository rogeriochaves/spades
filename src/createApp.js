const fs = require("fs");
const { promisify } = require("util");
const ncp = promisify(require("ncp").ncp);
const path = require("path");

module.exports = (name, cmd) => {
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

    if (cmd.serverless) serverlessPackage(name)

    console.log(
      "Your app is ready! Now run the following commands to get started:\n"
    );
    console.log(`  cd ${name}`);
    console.log("  npm install");
    console.log("  npm start\n");
  });
};


function serverlessPackage (name) {
  const handleFileErr = err => { if (err) console.log(err) };

  // delete all ssr files
  fs.unlink(path.join(name, "server.js"), handleFileErr);
  fs.unlink(path.join(name, "src", "index.ejs"), handleFileErr);
  fs.unlink(path.join(name, "package.json"), handleFileErr);
  fs.unlink(path.join(name, "webpack.config.js"), handleFileErr);

  fs.renameSync(
    path.join(name, "package.static.json"),
    path.join(name, "package.json"),
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
