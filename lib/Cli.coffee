# CLI abstraction layer

# https://github.com/chriso/cli
cli = require 'cli'


class Cli
  constructor: ->
    cli.parse null, ['up', 'down', 'build', 'console']
    @options = cli.options
    @args = cli.args
    @command = cli.command

# singleton
module.exports = new Cli
