const { run } = require("./helpers");
const fs = require("fs-extra");

const ONE_MINUTE = 60 * 1000;

test(
  "creates a new app with the same files of the boilerplate except the ignored folders",
  async () => {
    await run("npm -g uninstall elm-on-spades");
    await run("npm -g install .");
    await fs.remove("temp");
    await fs.ensureDir("temp");
    await run("cd temp && elm-generate app myapp");
    const newAppFiles = fs.readdirSync("temp/myapp");
    const ignoredFiles = fs
      .readFileSync("boilerplate/.gitignore.template")
      .toString("utf-8")
      .split("\n");
    ignoredFiles.push(".gitignore.template");
    ignoredFiles.push(".DS_Store");
    ignoredFiles.push("package.static.json");
    ignoredFiles.push("webpack.config.static.js");

    let boilerplateFiles = fs
      .readdirSync("boilerplate")
      .filter(folder => !ignoredFiles.includes(folder));
    boilerplateFiles = [".git", ".gitignore", ...boilerplateFiles];

    expect(newAppFiles).toEqual(boilerplateFiles);
  },
  ONE_MINUTE
);

test(
  "app installs, builds and test passes",
  async () => {
    await run("cd temp/myapp && npm install");
    await run("cd temp/myapp && npm test");
    await run("cd temp/myapp && npm run build");
  },
  ONE_MINUTE * 3
);

test(
  "runs a code generator, and the app still builds",
  async () => {
    await run("cd temp/myapp && elm-generate component Search");
    await run("cd temp/myapp && npm run build");
  },
  ONE_MINUTE * 3
);

test(
  "replaces <projectname> with <myapp>",
  async () => {
    const read = fs.readFileSync;
    expect(read("./temp/myapp/package.json", "utf8")).toMatch(/myapp/);
    expect(read("./temp/myapp/src/index.ejs", "utf8")).toMatch(/myapp/);
  },
  ONE_MINUTE * 3
);
