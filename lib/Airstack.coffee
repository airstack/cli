# todo !!!!
# xx1. manually tar a Dockerfile
# xx2. send tarfile to dockerode to see if it works
# xx3. get tar-async working
# 4. write code to output init scripts and add them to Dockerfile
# 5. convert callbacks to promises


cli = require './Cli'
Parser = require './Parser'
config = require './Config'
Builder = require './Builder'
VirtualMachine = require './VirtualMachine'
Docker = require './Docker'
Bundler = require './Bundler'


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
    @vm = new VirtualMachine
    cmd = cli.command()
    @runCmd cmd  if cmd

  runCmd: (cmd) ->
    console.log "Command is: #{cmd}"
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
    .then (yaml) =>
      config.init yaml
    .then =>
      @initDocker =>
        @build()

  initDocker: (callback) ->
    @vm.info (info) =>
      @info = info
      @vm.up =>
        @vm.ip (ip) =>
          console.log ip
          @ip = ip
          @docker = new Docker host: "http://#{@ip}", port: @info.DockerPort
          callback()

  # Must be called after initDocker
  build: ->
    builder = new Builder
    dockerfile = builder.buildfile()

    console.log "\n\n------------------\n# Dockerfile\n"
    console.log dockerfile
    console.log "------------------"

    bundler = new Bundler
    console.log "\n\nBundling tar file..."
    console.log bundler.getFile()
    console.log "\n\n"
    bundler.append 'Dockerfile', dockerfile, null, =>
      bundler.close =>
        @_build bundler.getFile()

  _build: (tarFile) ->
    imageName = config.getName()
    @docker.build tarFile, imageName, (error, stream) ->
      return console.error error  if error
      stream.on 'error', (data) ->
        error = data.toString()
        process.stderr.write "[ERROR] #{error}"
      stream.on 'data', (data) ->
        data = JSON.parse(data)
        if data.error
          error = data
          console.log "\n[ERROR]"
          console.log data
        else
          for k, v of data
            tab = if k == 'status' then '  ' else ''
            process.stdout.write "#{tab}#{v.toString()}"
      stream.on 'end', ->
        console.log "Built image: #{imageName}" unless error


module.exports = Airstack


