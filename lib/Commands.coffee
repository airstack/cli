config = require './Config'
Builder = require './Builder'
Docker = require './Docker'
Bundler = require './Bundler'
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
    @vm = opts.vm

  # getters/setters
  Object.defineProperties @prototype,
    samba:
      get: -> @_samba ?= new Samba
    docker:
      get: ->
        return @_docker  if @_docker
        ip = @vm.getDockerIP()
        port = @vm.getDockerPort()
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
    unless config.getBuildFile().file
      log.debug '[build]'.grey, 'skipping build step: no Dockerfile specified'
      return
    builder = new Builder
    bundler = new Bundler
    dockerURL = "http://#{@vm.getDockerIP()}:#{@vm.getDockerPort()}"
    builder.buildfile()
    .then (dockerfile) =>
      log.debug 'Dockerfile:'.bold, "\n", dockerfile
      log.debug 'Docker.tar:'.grey, bundler.getFile()
      bundler.append 'Dockerfile', dockerfile
    .then ->
      bundler.close()
    .then =>
      log.debug 'Sending Docker.tar:'.grey, dockerURL
      @docker.build bundler.getFile(), config.getName()

  run: ->
    @docker.run()

  cleanup: ->
    @samba.kill()
    # @docker.cleanup()

module.exports = Commands


