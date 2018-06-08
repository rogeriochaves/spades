const program = require("commander");
const createApp = require("./createApp");
const addRoute = require("./addRoute");

program.command("app <name>").action(createApp);
program.command("route").action(addRoute);

program.parse(process.argv);
