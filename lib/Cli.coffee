# CLI abstraction layer

# https://github.com/chriso/cli
cli = require 'cli'
cli_config = require '../config/cli.config'
path = require 'path'

class Cli
  constructor: ->
    cli.setApp path.resolve __dirname, '../package.json'
    cli.enable 'version'
    cli.parse null, cli_config.commands
    @options = cli.options
    @args = cli.args
    @command = cli.command

# singleton
module.exports = Cli
