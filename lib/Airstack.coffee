config = require './Config'
cli = require './Cli'
log = require './Logger'
Parser = require './Parser'
Commands = require './Commands'
VirtualMachine = require './VirtualMachine'
Promise = require 'bluebird'
charm = require('charm')(process)


class Airstack
  configFile: '.airstack.yml'

  constructor: ->
    cmd = cli.command()
    log.debug 'Command:'.bold, cmd
    Promise.all [
      @loadConfig()
      @createVM()
    ]
    .then =>
      @run cmd
    .then =>
      @watch()  if cmd is 'up'

  loadConfig: ->
    Parser.loadYaml @configFile
    .then (yaml) =>
      config.init yaml

  run: (cmd) ->
    @cmd ?= new Commands vm: @vm
    opts = cli.opts()
    switch cmd
      when 'up' then @cmd.up opts
      when 'down' then @cmd.down opts
      else cli.help()

  watch: ->
    charm.removeAllListeners '^C'
    charm.on '^C', ->
      # charm.display 'reset'
      clearInterval @_watchInterval
      charm.reset()
      process.exit()
    # Clear the screen while keeping log data after exit
    str = for i in [1..process.stdout.rows]
      "\n"
    charm.write str.join ''
    charm.reset()
    @_watchInterval = setInterval @status.bind(@), 1000

  status: ->
    @i ?= 0
    log.debug @i++

  createVM: ->
    # todo: parse config/<platform>.yml to get vm
    log.debug 'Using VirtualBox'
    @vm = VirtualMachine.factory 'VirtualBox'


module.exports = new Airstack
