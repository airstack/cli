cli = require './Cli'
Parser = require './Parser'
config = require './Config'
Builder = require './Builder'
VM = require '../plugins/VirtualBox'
Docker = require './Docker'
Bundler = require './Bundler'
log = require './Logger'


class Airstack
  # boot2docker info object
  info: {}
  # boot2docker host ip
  ip: null
  # Airstack config instance
  config: null
  # Dockerode instance
  docker: null

  constructor: ->
    @vm = new VM
    cmd = cli.command()
    @runCmd cmd  if cmd

  runCmd: (cmd) ->
    log.info "Command is: #{cmd}"
    opts = cli.opts()
    switch cmd
      when 'up' then @up opts
      when 'down' then @down opts
      else cli.help()

  # load .airstack.yml
  # make sure docker is ready; start boot2docker if needed
  # bundle Dockerfile, init scripts, and any other files into tar
  # send tar to Docker API build
  # send run cmd to Docker API
  # echo out ip address and port of app container
  up: (opts) ->
    Parser.loadYaml '.airstack.yml'
    .then (yaml) ->
      config.init yaml
    .then =>
      @vm.up()
    .then =>
      @build()

  build: ->
    @docker ?= new Docker host: "http://#{@vm.getIP()}", port: @vm.getDockerPort()
    builder = new Builder
    bundler = new Bundler
    builder.buildfile()
    .then (dockerfile) =>
      log.debug '[Dockerfile]'.bold, "\n#{dockerfile}"
      log.debug '[Docker.tar]'.bold, bundler.getFile()
      bundler.append 'Dockerfile', dockerfile
    .then ->
      bundler.close()
    .then =>
      @docker.build bundler.getFile(), config.getName()


module.exports = Airstack


