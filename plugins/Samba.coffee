# See https://github.com/airstack/docs/blob/master/samba.md

Process = require '../lib/Process'
Promise = require 'bluebird'
log = require '../lib/Logger'
config = require('../lib/Config').config
Ini = require '../lib/Ini'
utils = require '../lib/utils'
path = require 'path'
exec = Promise.promisify require('child_process').exec
fsReadFile = Promise.promisify require('fs').readFile
fsWriteFile = Promise.promisify require('fs').writeFile
_ = require 'lodash'


class Samba extends Process
  _detached: true
  _cmdPath: '/usr/local/Cellar/samba/3.6.23/sbin/'
  _cmd: 'smbd'
  # Run in interactive mode since node is piping stdout and stderr to files
  # http://www.samba.org/samba/docs/man/manpages/smbd.8.html
  _args: ['-F', '-S', '--no-process-group', '--debuglevel=1']
  _configFile: 'smb.conf'
  _mountTpl: """
  [{name}]
    hosts allow = 192.168.59.*
    guest ok = yes
    writeable = yes
    path = {path}
  """

  # Path in boot2docker where samba shares are mounted
  vmMountPath: '/mnt/airstack/smb/'

  constructor: ->
    @_args.push "--configfile=#{path.join config.paths.airstack.config, @_configFile}"
    super

  afterInit: ->
    fsReadFile @getConfigFile()
    .then (conf) =>
      @_ini = new Ini conf.toString()
      @initMounts config.mounts
    .then =>
      @updateConfig()
    .then =>
      @reload()  if @_pid

  initMounts: (mounts) ->
    mounts = for m in mounts
      from = path.resolve process.cwd(), m.from
      utils.fs.exists from
      .then ((m, from, exists) ->
        unless exists
          throw "Mount directory does not exist: #{from}"
        m
      ).bind null, m, from
    Promise.all mounts
    .then (mounts) =>
      @_mounts = mounts

  # Mount samba shares in boot2docker
  #
  # Updates config.mounts to point to mounted dirs in boot2docker.
  mount: ->
    # TODO: use VirtualMachine#runCmd to abstract boot2docker commands
    @_waitForVM()
    .then =>
      cmds = for m in @_mounts
        mountPath = "#{@vmMountPath}#{m.name}"
        # Rewrite mount.from to point to mounted samba share in boot2docker
        m.from = mountPath
        cmd = "boot2docker ssh sudo mkdir -vp #{mountPath}"
        log.debug '[samba]'.grey, cmd
        exec cmd, timeout: 1000
        .then ((name, mountPath) ->
          cmd = "boot2docker ssh sudo mount -t cifs //192.168.59.3/#{name} -o username=\"\",guest,port=9000,uid=\\`id -u docker\\`,gid=\\`id -g docker\\` #{mountPath}"
          log.debug '[samba]'.grey, cmd
          exec cmd, timeout: 5000
        ).bind null, m.name, mountPath
      Promise.all cmds

  updateConfig: ->
    for m in @_mounts
      @_ini.replaceSection m.name, @mountTpl m
    fsWriteFile @getConfigFile(), @_ini.toString()
    # todo: probably also push mounts back to config???

  mountTpl: (data) ->
    str = @_mountTpl
    for k,v of data
      str = str.replace ///{#{k}}///g, v
    str

  kill: ->
    # TODO: clean up mounts in VM
    # !!!!!!!
    super

  # Make sure VM is responding to ssh commands
  # TODO: use VirtualMachine#runCmd to abstract command
  _waitForVM: (maxRetries = 20, waitTime = 500) ->
    new Promise (resolve, reject) ->
      num = 0
      wait = ->
        setTimeout ->
          num++
          log.warn 'num', num
          retry()
        , waitTime
      retry = ->
        log.debug '[samba]'.grey, 'Waiting for VM to start:', "#{num}".grey
        if num >= maxRetries
          log.error '[samba]'.grey, 'Max retries reached waiting for VM'
          return reject ''
        exec 'boot2docker ssh echo up', timeout: 500
        .spread (stdout, stderr) ->
          if stdout and stdout.trim() == 'up'
            resolve()
          else
            wait()
        .catch (err) ->
          log.error 'err', num
          wait()
      retry()



module.exports = Samba


# MOUNTING
# 1. generate UUID container in node
# 2. create mounts in samba and vbox based on UUID and mount path in .airstack.yml
# 3. pass UUID as name of container when running
# http://docs.docker.com/reference/run/#name-name


# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Include Samba in cli output table
# see pidusage
# https://github.com/soyuka/pidusage/blob/master/lib/stats.js
# TODO NEXT NEXT
# Look at copying https://github.com/soyuka/promise-spawner

