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

    cmd.serverless ? serverlessPackage(name) : ssrPackage(name);

    console.log(
      "Your app is ready! Now run the following commands to get started:\n"
    );
    console.log(`  cd ${name}`);
    console.log("  npm install");
    console.log("  npm start\n");
  });
};


function serverlessPackage (name) {
  renameConfigFiles(name, "static");

  fs.unlink(path.join(name, "server.js"), handleFileErr)
  fs.unlink(path.join(name, "package.ssr.json"), handleFileErr)
  fs.unlink(path.join(name, "webpack.config.ssr.js"), handleFileErr)
}

function ssrPackage (name) {
  renameConfigFiles(name, "ssr")

  fs.unlink(path.join(name, "package.static.json"), handleFileErr)
  fs.unlink(path.join(name, "webpack.config.static.js"), handleFileErr)
}

function renameConfigFiles (name, type) {
  fs.renameSync(
    path.join(name, `package.${type}.json`),
    path.join(name, "package.json"),
  );

  fs.renameSync(
    path.join(name, `webpack.config.${type}.js`),
    path.join(name, "webpack.config.js")
  );

  fs.renameSync(
    path.join(name, 'src', `index.${type}.ejs`),
    path.join(name, 'src', `index.ejs`)
  );
}

function handleFileErr (err) {
  if (err) console.log(err)
}
