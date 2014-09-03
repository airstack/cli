# use https://www.npmjs.org/package/dockops ???

###
# Use this to get the vm process to query for memory
VBoxManage list runningvms
VM_UUID=$(VBoxManage list runningvms | grep boot2docker | cut -d ' ' -f 2 | sed 's/[{}]//g')
###

VirtualMachine = require '../lib/VirtualMachine'
ps = require '../lib/utils/process'
Promise = require 'bluebird'
log = require '../lib/Logger'


class VirtualBox extends VirtualMachine
  cmd:
    # spawn commands to see realtime output
    start: ['boot2docker', ['up']]
    down: ['boot2docker', ['down']]
    # exec commands
    ip: 'boot2docker ip'
    info: 'boot2docker info'

  constructor: ->
    @_info = {}
    @_ip = null

  # Getters/Setters
  Object.defineProperties @prototype,
    running:
      get: -> @state == 'running'
    state:
      get: -> @_info.State
      set: (state) -> @_state = state
    dockerIP:
      get: -> @_ip
    dockerPort:
      get: -> @_info.DockerPort

  # Get info and ip, return info
  info: ->
    silent =
      data: ps.output.silent
      error: ps.output.silent

    # todo: use cancellable and timeout
    info = ps.exec @cmd.info, silent
    .spread (stdout, stderr) =>
      try
        @_info = JSON.parse "#{stdout}".trim()
      catch e
        @_info = {}
      @state = @_info.State
      @_info
    .catch (err) =>
      @_info = {}

    ip = ps.exec @cmd.ip, silent
    .spread (stdout, stderr) =>
      @_ip = stdout or null
    .catch (err) =>
      log.warn 'Unable to get Docker IP'
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
      @_startVM()  unless @running

  down: ->
    ps.spawn @cmd.down

  status: ->
    @info()
    .then =>
      @state

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

  _startVM: ->
    ps.spawn @cmd.start,
      # Redirect error output to show progress in realtime
      error: ps.output.intercept
    .then =>
      @info()

module.exports = VirtualBox
