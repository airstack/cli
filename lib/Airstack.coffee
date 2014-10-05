AppState = require './AppState'
Config = require './Config'
Cli = require './Cli'
Logger = require './Logger'
ConfigParser = require './ConfigParser'
Commands = require './Commands'
VirtualMachine = require './VirtualMachine'
Promise = require 'bluebird'
charm = require('charm')()
StatusTable = require './StatusTable'
_ = require 'lodash'

class Airstack
  configFile: 'airstack.yml'
  updateStatsInterval: 1500

  constructor: ->
    # Catch ^C
    process.on 'SIGINT', @exit
    @init()

  init: ->
    @_config = new Config
    @cli = new Cli
    @log = new Logger
    @log.instance = @log

    @app = new AppState _config: @_config, cli: @cli, log: @log
    @app.vm = VirtualMachine.factory 'VirtualBox', app: @app

    # Listen to events
    @app.on 'exit', @exit

    cmd = @cli.command
    @log.debug 'Command:'.bold, cmd

    @loadConfig()
    .then =>
      @log.debug 'config', @_config.config
      @commands = new Commands app: @app
      @commands[cmd.replace '-', '_']()
    .then =>
      if cmd is 'up'
        @watch()
      else
        _.defer process.exit

  loadConfig: ->
    ConfigParser.load @configFile
    .then (yamljs) =>
      @_config.init yamljs, @cli.options.env

  watch: ->
    @charm = charm
    @charm.pipe process.stdout
    # @charm = charm
    # @charm.removeAllListeners '^C'
    # @charm.on '^C', =>
    #   @exit()
    # # Clear the screen while keeping log data after exit
    # str = for i in [1..process.stdout.rows]
    #   "\n"
    # @charm.write str.join ''
    # @charm.position 0, 0
    # @_watchInterval = setInterval @status.bind(@), 1000
    # @status()
    # @_updateStats()

  status: ->
    # @_statusTable ?= new StatusTable
    # @i ?= 0
    # data = for i in [1..5]
    #   obj = {}
    #   obj["key_#{i}"] = for j in [1..8]
    #     @i + j
    #   obj
    # data.push
    #   boot2docker: ['', '', '', @vm.state or '', @vm.dockerIP or '', @vm.dockerPort or '', '', '']
    # @charm.position 0, 0
    # @charm.write @_statusTable.render data
    # @charm.write "\n"
    # @i++

  _updateStats: ->
    @vm.info()
    .then =>
      setTimeout @_updateStats.bind(@), @updateStatsInterval

  exit: (evt) =>
    return if @_exiting
    @_exiting = true
    clearInterval @_watchInterval  if @_watchInterval
    @charm.destroy()  if @charm
    tasks = []
    tasks.push @commands.cleanup  if @commands
    Promise.all tasks
    .then ->
      _.defer ->
        process.exit evt and evt.code or 0

module.exports = new Airstack
