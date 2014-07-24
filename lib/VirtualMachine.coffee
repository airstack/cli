# TODO:
# - use promises instead of callbacks
# - use https://www.npmjs.org/package/dockops ???

spawn = require('child_process').spawn



class VirtualMachine
  cmd:
    start: ['boot2docker', ['up']]
    status: ['boot2docker', ['status']]
    ip: ['boot2docker', ['ip']]
    info: ['boot2docker', ['info']]

  constructor: ->
    @_state = null
    @_info = null

  isRunning: ->
    @_state == 'running'

  info: (callback) ->
    return callback @_info  if @_info
    output = ''
    @_runBoot2DockerCmd @cmd.info,
      data: (data) ->
        output += data
      done: (code) =>
        @_info = JSON.parse output.trim()
        @_state = @_info.state
        callback @_info if callback

  up: (callback) ->
    @status =>
      if @isRunning()
        callback() if callback
      else
        @_startVM callback

  status: (callback) ->
    @runBoot2DockerCmd @cmd.status,
      data: (data) =>
        @_state = "#{data}".trim()
      done: (code) ->
        callback()

  ip: (callback) ->
    return callback(@_ip) if @_ip
    output = ''
    @runBoot2DockerCmd @cmd.ip,
      data: (data) ->
        output += data.toString()
      done: (code) =>
        m = output.match /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
        @_ip = if m then m[0] else null
        callback @_ip

  build: (tarfile, imageName, callback) ->
    # todo !!!!
    # ...... WHEN I GET BACK ......
    # 1. manually tar a Dockerfile
    # 2. send tarfile to dockerode to see if it works
    #    via the serialfile???
    # 3. get tar-async working
    # 4. write code to output init scripts and add them to Dockerfile

  upgrade: (callback) ->
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

  runBoot2DockerCmd: (cmd, callbacks) ->
    unless @isRunning()
      @_startVM =>
        @_runBoot2DockerCmd cmd, callbacks
    else
      @_runBoot2DockerCmd cmd, callbacks

  _runBoot2DockerCmd: (cmd, callbacks) ->
    proc = spawn.apply null, cmd
    proc.stdout.on 'data', (data) ->
      if callbacks.data
        callbacks.data data
      else
        process.stdout.write data.toString()
    proc.stderr.on 'data', (data) ->
      if callbacks.error
        callbacks.error data
      else
        process.stderr.write data.toString()
    proc.on 'exit', (code) ->
      callbacks.done code  if callbacks.done

  _startVM: (callback) ->
    console.log '[STARTING VM]'
    console.log this
    @_runBoot2DockerCmd @cmd.start,
      done: (code) ->
        callback() if callback


module.exports = VirtualMachine
