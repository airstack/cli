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
  # Dockerode instance
  docker: null

  constructor: (opts) ->
    @vm = opts.vm
    @samba = new Samba

  # load .airstack.yml
  # make sure docker is ready; start boot2docker if needed
  # bundle Dockerfile, init scripts, and any other files into tar
  # send tar to Docker API build
  # send run cmd to Docker API
  # echo out ip address and port of app container
  up: (opts) ->
    Promise.all [
      @samba.up()
      @vm.up()
    ]
    .then =>
      @build()

  down: ->
    Promise.all [
      @samba.kill()
      @vm.down()
    ]
    .then ->
      log.info '[ DONE ]'.grey

  build: ->
    throw 'Invalid Docker address'  unless @vm.getDockerIP() and @vm.getDockerPort()
    docker = new Docker host: "http://#{@vm.getDockerIP()}", port: @vm.getDockerPort()
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
    .then ->
      log.debug 'Sending Docker.tar:'.grey, dockerURL
      docker.build bundler.getFile(), config.getName()

  cleanup: ->
    @samba.kill()

module.exports = Commands


