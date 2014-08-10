config = require './Config'
cli = require './Cli'
log = require './Logger'
Parser = require './Parser'
Commands = require './Commands'
VirtualMachine = require './VirtualMachine'
Promise = require 'bluebird'
charm = require('charm')(process)
StatusTable = require './StatusTable'


class Airstack
  configFile: '.airstack.yml'
  updateStatsInterval: 1500

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
      if cmd is 'up'
        @watch()
      else
        process.exit()

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
    charm.on '^C', =>
      clearInterval @_watchInterval
      charm.reset()
      # todo: move cmd.cleanup to own function and listen for process exit
      # currently cmd.clienup will not be executed if user ^c quickly on air up
      @cmd.cleanup()
      .then ->
        process.exit()
    # Clear the screen while keeping log data after exit
    str = for i in [1..process.stdout.rows]
      "\n"
    charm.write str.join ''
    charm.position 0, 0
    @_watchInterval = setInterval @status.bind(@), 1000
    @status()
    @_updateStats()

  status: ->
    @_statusTable ?= new StatusTable
    @i ?= 0
    data = for i in [1..5]
      obj = {}
      obj["key_#{i}"] = for j in [1..8]
        @i + j
      obj
    data.push
      boot2docker: ['', '', '', @vm.getState() or '', @vm.getDockerIP() or '', @vm.getDockerPort() or '', '', '']
    charm.position 0, 0
    charm.write @_statusTable.render data
    charm.write "\n"
    @i++

  createVM: ->
    # todo: parse config/<platform>.yml to get vm
    log.debug 'Using VirtualBox'.grey
    @vm = VirtualMachine.factory 'VirtualBox'

  _updateStats: ->
    @vm.info()
    .then =>
      setTimeout @_updateStats.bind(@), @updateStatsInterval

module.exports = new Airstack
