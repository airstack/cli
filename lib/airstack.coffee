# todo !!!!
# xx1. manually tar a Dockerfile
# xx2. send tarfile to dockerode to see if it works
# 3. get tar-async working
# 4. write code to output init scripts and add them to Dockerfile
# 5. convert callbacks to promises


cli = require './Cli'
parser = require './Parser'
Config = require './Config'
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

  up: (opts) ->
    @loadYaml()
    @initDocker =>
      @build 'testimage'

  loadYaml: (filename = '.airstack.yml') ->
    return @config  if @config
    try
      yml = parser.load filename
    catch e
      console.log '[ERROR]'
      console.error e.message
      return false
    @config = new Config yml
    console.log @config
    @config

  initDocker: (callback) ->
    @vm.info (info) =>
      @info = info
      console.log '[INFO]'
      console.log @info
      @vm.up =>
        @vm.ip (ip) =>
          @ip = ip
          @docker = new Docker host: "http://#{@ip}", port: @info.DockerPort
          callback()

  # Must be called after initDocker
  build: ->
    builder = new Builder @config
    dockerfile = builder.buildfile()
    bundler = new Bundler
    bundler.append 'Dockerfile', dockerfile, null, =>
      bundler.close()
      @_build bundler.tarFile

  _build: (tarFile) ->
    @docker.build tarFile, @config.getName(), (error, stream) ->
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


