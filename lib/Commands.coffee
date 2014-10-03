Builder = require './Builder'
Docker = require './Docker'
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
    {@vm, @config} = opts

  # Getters/Setters
  Object.defineProperties @prototype,
    samba:
      get: -> @_samba ?= new Samba config: @config
    docker:
      get: ->
        return @_docker  if @_docker
        ip = @vm.dockerIP
        port = @vm.dockerPort
        log.error "#{ip} #{port}"
        if ip and port
          @_docker = new Docker host: ip, port: port, protocol: 'http'
        else
          @_docker = null
          throw 'Invalid Docker address'

  # load .airstack.yml
  # make sure docker is ready; start boot2docker if needed
  # bundle Dockerfile, init scripts, and any other files into tar
  # send tar to Docker API build
  # send run cmd to Docker API
  # echo out ip address and port of app container
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

  build: ->
    # unless config.buildFile
    #   log.debug '[build]'.grey, 'skipping build step: no Dockerfile specified'
    #   return
    builder = new Builder config: @config
    builder.build()
  console: ->
    @make.make 'console',
      env:
        # Echo commands that start a terminal to stdout for capture
        # See bin/airstack
        TERM: 'printf "EXEC::%s" '
    .then (a, b) =>
      process.stdout.write a.data
      process.exit 2

  run: ->
    @docker.run()

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


