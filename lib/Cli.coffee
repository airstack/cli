# CLI abstraction layer

# https://github.com/chriso/cli
cli = require 'cli'


class Cli
  constructor: ->
    @_parse()

  _parse: ->
    cli.parse null, ['up', 'down', 'deploy', 'fetch']
    @

  command: ->
    cli.command

  opts: ->
    {
      args: cli.args
      options: cli.options
    }

# singleton
module.exports = new Cli
