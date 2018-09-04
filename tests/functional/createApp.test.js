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
          .readFileSync("boilerplate/.gitignore.template")
          .toString("utf-8")
          .split("\n");
        ignoredFiles.push(".gitignore.template");
        ignoredFiles.push(".DS_Store");

        let boilerplateFiles = fs
          .readdirSync("boilerplate")
          .filter(folder => !ignoredFiles.includes(folder));
        boilerplateFiles = [".gitignore", ...boilerplateFiles];

        expect(newAppFiles).toEqual(boilerplateFiles);
      }),
  ONE_MINUTE
);

test(
  "runs a code generator and builds the app",
  () =>
    run("cd temp/myapp && elm-generate component Search")().then(
      run("cd temp/myapp && npm install && npm install && npm run build")
    ),
  ONE_MINUTE * 3
);
