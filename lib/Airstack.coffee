Config = require './Config'
Cli = require './Cli'
log = require './Logger'
ConfigParser = require './ConfigParser'
Commands = require './Commands'
VirtualMachine = require './VirtualMachine'
Promise = require 'bluebird'
charm = require('charm')(process)
StatusTable = require './StatusTable'
_ = require 'lodash'

class Airstack
  configFile: 'airstack.yml'
  updateStatsInterval: 1500

  constructor: ->
    @_config = new Config
    @init()

  init: ->
    @cli = new Cli
    cmd = @cli.command
    log.debug 'Command:'.bold, cmd
    Promise.all [
      @loadConfig()
      @createVM()
    ]
    .then =>
      @commands = new Commands _config: @_config, vm: @vm
      @commands[cmd.replace '-', '_'] @cli
    .then =>
      if cmd is 'up'
        @watch()
      else
        _.defer process.exit

  loadConfig: ->
    ConfigParser.load @configFile
    .then (yamljs) =>
      @_config.init yamljs, @cli.options.env
      log.debug 'config', @_config.config

  watch: ->
    charm.removeAllListeners '^C'
    charm.on '^C', =>
      clearInterval @_watchInterval
      charm.reset()
      # todo: move cmd.cleanup to own function and listen for process exit
      # currently cmd.cleanup will not be executed if user ^c quickly on air up
      @commands.cleanup()
      .then ->
        _.defer process.exit
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
      boot2docker: ['', '', '', @vm.state or '', @vm.dockerIP or '', @vm.dockerPort or '', '', '']
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
