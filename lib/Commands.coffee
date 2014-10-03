# Builder = require './Builder'
# Docker = require './Docker'
Make = require '../plugins/Make'
log = require './Logger'
Promise = require 'bluebird'
Samba = require '../plugins/Samba'


class Commands
  # boot2docker info object
  info: {}
  # boot2docker host ip
  ip: null
  # Airstack config instance
  config: null

  constructor: (opts) ->
    {@vm, @_config, @cli} = opts
    @config = @_config.config
    @make = new Make

  # Getters/Setters
  Object.defineProperties @prototype,
    samba:
      get: -> @_samba ?= new Samba config: @config

  up: ->
    Promise.all [
      @samba.up()
      @vm.up()
    ]
    .then =>
      Promise.all [
        @samba.mount()
        @build()
      ]
    .then =>
      @run()

  down: ->
    Promise.all [
      @samba.kill()
      @vm.down()
    ]
    .then ->
      log.info '[ DONE ]'.grey

  build: (config = @config) ->
    log.debug 'build config:', config
    @make.make 'build', config

  build_all: ->
    @all 'build'

  clean: (config = @config) ->
    @make.make 'clean', config

  clean_all: ->
    @all 'clean'

  all: (cmd) ->
    Promise.all (@[cmd] config for k,config of @_config.environments)

  console: ->
    @make.make 'console', @config,
      env:
        TERM: 'printf "EXEC::%s" '
    .then ->
      # Exit with code=2 to trigger cli to eval EXEC string
      # See bin/airstack
      process.exit 2

  run: ->
    # @docker.run()

  cleanup: ->
    @samba.kill()
    # @docker.cleanup()
    # IDEA: instead of specific cleanup calls, use "stop" event.
    #   A process responding to a stop event should remove itself as a listener when it's done.
    #   Exit after all stop listeners have been removed.
    #   Pros: keeps code more modular
    #   Cons: harder to control order of stop events if needed

    # Optimization: spawn a process that does the cleanup steps; useful for immediate exit; does this break unix philosophy?

module.exports = Commands


