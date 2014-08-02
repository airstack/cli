config = require './Config'
Builder = require './Builder'
Docker = require './Docker'
Bundler = require './Bundler'
log = require './Logger'
Promise = require 'bluebird'


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

  # load .airstack.yml
  # make sure docker is ready; start boot2docker if needed
  # bundle Dockerfile, init scripts, and any other files into tar
  # send tar to Docker API build
  # send run cmd to Docker API
  # echo out ip address and port of app container
  up: (opts) ->
    Promise.all [
      # @samba.up()
      @vm.up()
    ]
    .then =>
      @build()

  build: ->
    @docker ?= new Docker host: "http://#{@vm.getDockerIP()}", port: @vm.getDockerPort()
    builder = new Builder
    bundler = new Bundler
    builder.buildfile()
    .then (dockerfile) =>
      log.debug 'Dockerfile:'.bold, "\n#{dockerfile}"
      log.debug 'Docker.tar:'.grey, bundler.getFile()
      bundler.append 'Dockerfile', dockerfile
    .then ->
      bundler.close()
    .then =>
      log.debug "Sending Docker.tar:".grey, "http://#{@vm.getDockerIP()}:#{@vm.getDockerPort()}"
      @docker.build bundler.getFile(), config.getName()


module.exports = Commands


