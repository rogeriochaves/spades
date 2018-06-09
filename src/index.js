const program = require("commander");
const createApp = require("./createApp");
const { addRoute, addView } = require("./transformCode");

program.command("app <name>").action(createApp);
program.command("route <Name>").action(addRoute);
program.command("view <Name>").action(addView);

program.parse(process.argv);
