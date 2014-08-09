# Process.
#
# If the process command starts a daemon, call #lookupPid after
# calling #start to ensure the correct pid is obtained.

Promise = require 'bluebird'
path = require 'path'
spawn = require('child_process').spawn
exec = Promise.promisify require('child_process').exec
fsOpen = Promise.promisify require('fs').open
fsExists = Promise.promisify require('fs').exists
config = require './Config'
Utils = require './Utils'
log = require './Logger'


class Process
  # Example:
  # _cmd: 'ls'
  # _args: ['-la']
  _cmdPath: ''
  _cmd: null
  _args: []
  _opts: {}
  _detached: false
  _configFile: null

  _process: null
  _pid: null
  _logFiles:
    stdout: null
    stderr: null
  _initialized: false

  stdout: null
  stderr: null

  constructor: ->
    @_fullCmd = path.join @_cmdPath, @_cmd

  toString: ->
    [@_cmdPath + @_cmd].concat(@_args).join ' '

  pid: ->
    @_pid

  # Override in subclass as needed.
  # Every method that returns a Promise should first call init.
  init: ->
    return Promise.resolve()  if @_initialized
    @initConfig()
    .then @initLogs.bind @
    .then =>
      @_initialized = true

  # Run process.
  # @param {String} cmd   Command to start
  # @param {Object} opts  Options
  # opts.fork {Boolean}   Defaults to false
  # opts.args {Array}     Cmd args to use when starting process
  # @return Promise
  start: ->
    log.info "[#{@_cmd}]".grey, 'starting'
    @init()
    .then =>
      if @_detached
        @_opts.detached = true
        @_opts.stdio = ['ignore', @stdout, @stderr]
      child = spawn @_fullCmd, @_args, @_opts
      @_pid = child.pid
      if @_detached
        child.unref()
        child = null
      @_process = child

  up: ->
    @init()
    .then @attach.bind @
    .then (pid) =>
      @start()  unless pid

  attach: ->
    @init()
    .then @lookupPid.bind @
    .then (pid) =>
      if pid
        log.info "[#{@_cmd}]".grey, 'already running:', pid
      else
        log.info "[#{@_cmd}]".grey, 'not running'
      @_pid = pid

  lookupPid: ->
    # get the command started by launchd (pid=1)
    # `pgrep -P 1 -f '@toString()'`
    # OR
    # get the oldest and assume it's the parent
    # `pgrep -o -f '@toString()'`
    # todo: use `ps` then filter results to find pid of running process
    # https://github.com/neekey/ps/blob/master/lib/index.js
    @init()
    .then =>
      exec "pgrep -o -f #{@_fullCmd}", timeout: 100
    .spread (stdout, stderr) ->
      parseInt stdout
    .catch (err) ->
      unless err.cause.code is 1
        log.error '[pgrep]'.grey, err
        Promise.reject err

  status: ->
    # todo: implement by querying ps and getting cpu, mem, etc.
    @init()

  kill: (signal = 'SIGTERM') ->
    log.info "[#{@_cmd}]".grey, 'stopping'
    @init()
    .then =>
      pid = @_process and @_process.pid or @_pid
      throw { code: 'ESRCH', errno: 'ESRCH', syscall: 'kill' }  unless pid
      process.kill pid, signal
    .catch (err) =>
      # Rethrow unless error was due nonexistent process
      if err.code is 'ESRCH'
        log.warn "[#{@_cmd}]".grey, 'did not exist', @_pid
      else
        throw err

  reload: ->
    throw 'Process#reload must be implemented in subclass.'

  # Initialize config file if @configFile is present.
  initConfig: ->
    return Promise.resolve()  unless @_configFile
    # Copy default config file from cli/config/* if config is not present
    conf = config.getConfigFile @_configFile
    fsExists conf
    .then (configExists) =>
      return true  if configExists
      src = path.join __dirname, '../config', @_configFile
      log.debug '[ init ]'.grey, "Copying #{src} to #{conf}"
      Utils.mkdir config.getConfigDir()
      .then ->
        exec "cp #{src} #{conf}", timeout: 100
      .spread (stdout, stderr) ->
        log.debug stderr  if stderr
    .then =>
      @_configFile = conf

  # todo: add log rotation or truncation somewhere
  # http://stackoverflow.com/questions/11403953/winston-how-to-rotate-logs
  initLogs: ->
    return Promise.resolve()  if @stdout and @stderr
    dir = config.getLogDir @_cmd
    @_logFiles.stdout = path.join dir, 'stdout.log'  unless @_logFiles.stdout
    @_logFiles.stderr = path.join dir, 'stderr.log'  unless @_logFiles.stderr
    Utils.mkdir dir
    .then =>
      Promise.join(
        fsOpen @_logFiles.stdout, 'a'
        fsOpen @_logFiles.stderr, 'a'
      ).then (fds) =>
        [@stdout, @stderr] = fds


module.exports = Process
