# See https://github.com/airstack/docs/blob/master/samba.md

Process = require '../lib/Process'
Promise = require 'bluebird'
log = require '../lib/Logger'
config = require '../lib/Config'
Ini = require '../lib/Ini'
path = require 'path'
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

  _init: ->
    fsReadFile @getConfigFile()
    .then (conf) =>
      @_ini = new IniParser conf.toString()
      @initMounts config.getMounts()
      @updateConfig()

  initMounts: (mounts) ->
    @_mounts = for m in mounts
      mountPath = path.resolve path.normalize m
      m = path.relative process.cwd(), m
      m = _.compact m.split path.sep
      m = if m.length then "__#{m.join '-'}" else ''
      {
        name: "#{config.getName()}_#{config.uuid}#{m}"
        path: mountPath
      }

  updateConfig: ->
    for m in @_mounts
      @_ini.replaceSection m.name, @mountTpl m
    fsWriteFile @getConfigFile(), @_ini.toString()

  mountTpl: (data) ->
    str = @_mountTpl
    for k,v of data
      str = str.replace ///{#{k}}///g, v
    str

    # todo: probably also push mounts back to config???

    # async: add dirs in virtualbox
    # after samba starts,


module.exports = Samba
