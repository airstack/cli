# use https://www.npmjs.org/package/dockops ???

###
# Use this to get the vm process to query for memory
VBoxManage list runningvms
VM_UUID=$(VBoxManage list runningvms | grep boot2docker | cut -d ' ' -f 2 | sed 's/[{}]//g')
###

VirtualMachine = require '../lib/VirtualMachine'
spawn = require('child_process').spawn
log = require '../lib/Logger'
_ = require 'lodash'


class VirtualBox extends VirtualMachine
  cmd:
    start: ['boot2docker', ['up']]
    ip: ['boot2docker', ['ip']]
    info: ['boot2docker', ['info']]
    down: ['boot2docker', ['down']]

  constructor: ->
    @_state = null
    @_info = null
    @_ip = null

  isRunning: ->
    @_state == 'running'

  getState: ->
    @_info.State

  getDockerIP: ->
    @_ip

  getDockerPort: ->
    @_info.DockerPort

  # Get info and ip, return info
  info: ->
    # todo: use cancellable and timeout
    # @runBoot2DockerCmd @cmd.info, data: ->, error: ->, timeout: 1000
    info = @_runBoot2DockerCmd @cmd.info, data: @_streams.silent
      .then (data, error, code) =>
        try
          @_info = JSON.parse "#{data}".trim()
        catch e
          @_info = {}
        @_state = @_info.State
        @_info
      .catch (e) =>
        @_info = {}

    ip = @_runBoot2DockerCmd @cmd.ip, data: @_streams.silent, error: @_streams.ignore
      .then (data) =>
        log.debug 'ip:'.bold, data
        @_ip = data or null
      .catch (e) =>
        @_ip = null

    Promise.all [
      info
      ip
    ]
    .then =>
      @_info

  up: ->
    @info()
    .then =>
      @_startVM()  unless @isRunning()

  down: ->
    @_runBoot2DockerCmd @cmd.down

  status: ->
    @info()
    .then =>
      @getState()

  upgrade: ->
    # http://docs.docker.com/installation/mac/
    # https://github.com/boot2docker/osx-installer/releases
    # THIS PROCESS UPGRADES THE boot2docker.iso but not the tools. WTF?
    # echo out current version `boot2docker version`
    # `boot2docker stop`
    # `boot2docker download`
    # `boot2docker up`
    # then echo new version
    # OR FOR SAFETY ...
    # `boot2docker delete && boot2docker init`

  runBoot2DockerCmd: (cmd, opts) ->
    if @isRunning()
      @_runBoot2DockerCmd cmd, opts
    else
      @_startVM()
      .then =>
        @_runBoot2DockerCmd cmd, opts

  _runBoot2DockerCmd: (cmd, opts = {}) ->
    debug = (type, msg) ->
      log.debug msg.toString()
      msg
    _.defaults opts,
      data: debug.bind null, '[stdout]'.grey
      error: debug.bind null, '[stderr]'.grey
      timeout: null
    _data = ''
    _error = ''
    cmdStr = @_cmdToString cmd
    # todo: use cancellable and timeout
    new Promise (resolve, reject) ->
      log.debug '[ RUN  ]'.grey, cmdStr
      proc = spawn.apply null, cmd
      proc.stdout.on 'data', (data) ->
        _data += opts.data data
      proc.stderr.on 'data', (data) ->
        _error += opts.error data
      proc.on 'exit', (code) ->
        log.debug '[ DONE ]'.grey, cmdStr, '=>', code
        if code is 0
          resolve _data, _error, code
        else
          reject _error, _data, code

  _cmdToString: (cmd) ->
    if _.isString cmd
      cmd
    else if _.isArray cmd
      "#{cmd[0]} #{(cmd[1] || []).join ' '}"
    else
      cmd.toString()

  _startVM: ->
    @_runBoot2DockerCmd @cmd.start,
      # Redirect error output to show progress in realtime
      error: @_streams.intercept
    .then =>
      @info()


  # Use with _runBoot2DockerCmd streams to handle output
  _streams:
    # Redirect output to log.debug
    intercept: (msg) ->
      process.stderr.write msg.toString()
      ''
    # Discard output
    ignore: (msg) ->
      ''
    # Suppress debug output
    silent: (msg) ->
      msg

module.exports = VirtualBox
