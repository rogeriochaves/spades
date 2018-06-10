const program = require("commander");
const createApp = require("./createApp");
const {
  addRoute,
  addComponentView,
  addComponentTypes
} = require("./transformCode");

program.command("app <name>").action(createApp);
program.command("route <Name>").action(addRoute);
program.command("component-view <Name>").action(addComponentView);
program.command("component-types <Name>").action(addComponentTypes);

program.parse(process.argv);
