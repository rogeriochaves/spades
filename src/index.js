const program = require("commander");
const createApp = require("./createApp");
const {
  addRoute,
  addComponent,
  addComponentView,
  addComponentTypes,
  addComponentUpdate
} = require("./transformCode");

program.command("app <name>").option('--serverless', 'Generates app without prerender server').action(createApp);
program.command("route <Name>").action(addRoute);
program.command("component <Name>").action(addComponent);
program.command("component-view <Name>").action(addComponentView);
program.command("component-types <Name>").action(addComponentTypes);
program.command("component-update <Name>").action(addComponentUpdate);

program.parse(process.argv);
