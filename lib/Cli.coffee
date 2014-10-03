# CLI abstraction layer

# https://github.com/chriso/cli
cli = require 'cli'
cli_config = require '../config/cli.config'

class Cli
  constructor: (opts) ->
    {@config} = opts
    cli.enable 'version'
    cli.setApp './package.json'
    cli.parse null, cli_config.commands
    @options = cli.options
    @args = cli.args
    @command = cli.command

# singleton
module.exports = Cli
