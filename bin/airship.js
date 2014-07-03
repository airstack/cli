#! /usr/bin/env node

// https://github.com/chriso/cli
var cli = require('cli');

cli.parse(null, ['up', 'down', 'deploy', 'fetch']);

console.log('Command is: ' + cli.command);
