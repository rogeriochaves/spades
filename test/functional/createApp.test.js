const { run } = require("./helpers");
const fs = require("fs");

const ONE_MINUTE = 60 * 1000;

test(
  "creates a new app with the same files of the boilerplate except the ignored folders",
  () =>
    run(`npm -g install .`)()
      .then(run("rm -rf temp; mkdir temp"))
      .then(run("cd temp && elm-generate app myapp"))
      .then(() => {
        const newAppFiles = fs.readdirSync("temp/myapp");
        const ignoredFiles = fs
          .readFileSync("boilerplate/.gitignore")
          .toString("utf-8")
          .split("\n");

        const boilerplateFiles = fs
          .readdirSync("boilerplate")
          .filter(folder => !ignoredFiles.includes(folder));

        expect(newAppFiles).toEqual(boilerplateFiles);
      }),
  ONE_MINUTE
);
