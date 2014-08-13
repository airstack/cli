# See https://github.com/airstack/docs/blob/master/samba.md

Process = require '../lib/Process'
Promise = require 'bluebird'
log = require '../lib/Logger'
config = require '../lib/Config'
Ini = require '../lib/Ini'
utils = require '../lib/utils'
path = require 'path'
exec = Promise.promisify require('child_process').exec
fsReadFile = Promise.promisify require('fs').readFile
fsWriteFile = Promise.promisify require('fs').writeFile
_ = require 'lodash'

CONFIGFILE = 'smb.conf'


class Samba extends Process
  _detached: true
  _cmdPath: '/usr/local/Cellar/samba/3.6.23/sbin/'
  _cmd: 'smbd'
  # Run in interactive mode since node is piping stdout and stderr to files
  # http://www.samba.org/samba/docs/man/manpages/smbd.8.html
  _args: ['-F', '-S', '--no-process-group', '--debuglevel=1', "--configfile=#{config.getConfigFile(CONFIGFILE)}"]
  _configFile: CONFIGFILE

  _mountTpl: """
  [{name}]
    hosts allow = 192.168.59.*
    guest ok = yes
    writeable = yes
    path = {path}
  """

  constructor: ->
    super

  afterInit: ->
    fsReadFile @getConfigFile()
    .then (conf) =>
      @_ini = new Ini conf.toString()
      @initMounts config.getMounts()
    .then =>
      @updateConfig()
    .then =>
      @reload()  if @_pid

  initMounts: (mounts) ->
    mounts = for m in mounts
      mountPath = path.resolve path.normalize m
      utils.fs.exists mountPath
      .then ((mountPath, exists) ->
        return null  unless exists
        m = path.relative process.cwd(), mountPath
        m = _.compact m.split path.sep
        m = if m.length then "__#{m.join '-'}" else ''
        {
          name: "#{config.getName()}_#{config.uuid}#{m}"
          path: mountPath
        }
      ).bind null, mountPath
    Promise.all mounts
    .then (mounts) =>
      @_mounts = _.compact mounts

  mount: ->
    # TODO: use VirtualMachine#runCmd to abstract boot2docker commands
    @_waitForVM()
    .then =>
      cmds = for m in @_mounts
        mountPath = "/mnt/airstack/samba/#{m.name}"
        cmd = "boot2docker ssh sudo mkdir -vp #{mountPath}"
        log.debug '[ vm ]'.grey, cmd
        exec cmd, timeout: 1000
        .then ((name, mountPath) ->
          cmd = "boot2docker ssh sudo mount -t cifs //192.168.59.3/#{name} -o username=\"\",guest,port=9000,uid=\\`id -u docker\\`,gid=\\`id -g docker\\` #{mountPath}"
          log.debug '[ vm ]'.grey, cmd
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
        log.debug '[ vm ]'.grey, 'Waiting for VM to start:', num
        if num >= maxRetries
          log.error '[ vm ]'.grey, 'Max retries reached waiting for VM'
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
