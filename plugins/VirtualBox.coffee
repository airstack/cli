# use https://www.npmjs.org/package/dockops ???

###
# Use this to get the vm process to query for memory
VBoxManage list runningvms
VM_UUID=$(VBoxManage list runningvms | grep boot2docker | cut -d ' ' -f 2 | sed 's/[{}]//g')
###

spawn = require('child_process').spawn
log = require '../lib/Logger'
_ = require 'lodash'


class VirtualBox
  cmd:
    start: ['boot2docker', ['up']]
    ip: ['boot2docker', ['ip']]
    info: ['boot2docker', ['info']]

  constructor: ->
    @_state = null
    @_info = null
    @_ip = null

  isRunning: ->
    @_state == 'running'

  getIP: ->
    @_ip

  getState: ->
    @_info.State

  getDockerPort: ->
    @_info.DockerPort

  info: ->
    return Promise.resolve @_info  if @_info
    # Get info and ip, return info
    Promise.all [
      @_runBoot2DockerCmd @cmd.info
        .then (data) =>
          @_info = JSON.parse data.trim()
          log.debug 'boot2docker info'.bold, @_info
          @_state = @_info.State
          @_info
      @ip()
    ]
    .then =>
      @_info

  up: ->
    @info()
    .then =>
      @_startVM()  unless @isRunning()

  status: ->
    @info()
    .then =>
      @getState()

  ip: ->
    return Promise.resolve @_ip  if @_ip
    @_runBoot2DockerCmd @cmd.ip,
      error: @ignore
    .then (data) =>
      m = data.match /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
      @_ip = m and m[0] or null

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

  cmdToString: (cmd) ->
    if _.isString cmd
      cmd
    else if _.isArray cmd
      "#{cmd[0]} #{(cmd[1] || []).join ' '}"
    else
      cmd.toString()

  runBoot2DockerCmd: (cmd, streams) ->
    if @isRunning()
      @_runBoot2DockerCmd cmd, streams
    else
      @_startVM()
      .then =>
        @_runBoot2DockerCmd cmd, streams

  _runBoot2DockerCmd: (cmd, streams = {}) ->
    _.defaults streams,
      data: (msg) ->
        log.debug msg.toString()
        msg
      error: (msg) ->
        log.error msg.toString()
        msg
    _data = ''
    _error = ''
    cmdStr = @cmdToString cmd
    new Promise (resolve, reject) ->
      log.debug '[ RUN  ]'.bold, cmdStr
      proc = spawn.apply null, cmd
      proc.stdout.on 'data', (data) ->
        _data += streams.data data
      proc.stderr.on 'data', (data) ->
        _error += streams.error data
      proc.on 'exit', (code) ->
        log.debug '[ DONE ]'.bold, cmdStr, ' :: ', code, ' :: ', if _error then 'with error output' else 'no error output'
        if _error
          reject _error, code, _data
        else
          resolve _data, code, _error

  _startVM: ->
    @_runBoot2DockerCmd @cmd.start,
      # `boot2docker up` sends output to stderr; WTF?
      error: @intercept
    .then =>
      @info()

  intercept: (msg) ->
    log.debug msg.toString()
    ''

  ignore: (msg) ->
    ''

module.exports = VirtualBox
