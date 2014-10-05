# Process.
#
# If the process command starts a daemon, call #lookupPid after
# calling #start to ensure the correct pid is obtained.

Promise = require 'bluebird'
Ps = require './Ps'
path = require 'path'
fsOpen = Promise.promisify require('fs').open
config = require './Config'
utils = require './utils'


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

  # Automatically lookup pid if not set
  _autoLookup: true

  _pid: null
  _logFiles:
    stdout: null
    stderr: null
  _initialized: false

  stdout: null
  stderr: null

  constructor: (opts) ->
    {@app} = opts
    @log = @app.log
    @ps = new Ps app: @app
    @_fullCmd = path.join @_cmdPath, @_cmd

  toString: ->
    [@_cmdPath + @_cmd].concat(@_args).join ' '

  pid: ->
    @_pid

  # Override in subclass.
  afterInit: ->

  init: (autoLookup = @_autoLookup) ->
    return Promise.resolve()  if @_initialized
    @initConfig()
    .then =>
      @initLogs()
    .then =>
      @lookupPid()  if autoLookup and not @_pid
    .then =>
      @afterInit()
    .then =>
      @_initialized = true

  # Run process.
  # @param {String} cmd   Command to start
  # @param {Object} opts  Options
  # opts.fork {Boolean}   Defaults to false
  # opts.args {Array}     Cmd args to use when starting process
  # @return Promise
  start: ->
    @log.info "[#{@_cmd}]".grey, 'starting'
    @init false
    .then =>
      if @_detached
        @_opts.detached = true
        @_opts.stdio = ['ignore', @stdout, @stderr]
      @ps.spawn @_fullCmd, @_args, @_opts
    .then (results) =>
      @_pid = results.pid

  # Starts process only if not already running.
  up: ->
    @init()
    .then =>
      @start()  unless @_pid

  lookupPid: ->
    @ps.pgrep @_fullCmd, oldest: true
    .then (pids) =>
      @_pid = pids[0]
      if @_pid
        @log.info "[#{@_cmd}]".grey, 'already running:', @_pid
      else
        @log.info "[#{@_cmd}]".grey, 'not running'

  status: ->
    # todo: implement by querying ps and getting cpu, mem, etc.
    @init()
    # get stats for all relevant processes and sum them
    # ps -A -o pid,%cpu,%mem,rss,time,etime,command | grep "[V]Box"

  kill: (signal = 'SIGTERM') ->
    @log.info "[#{@_cmd}]".grey, 'stopping'
    @ps.killAll @_fullCmd, signal

  reload: ->
    @log.info "[#{@_cmd}]".grey, 'reloading'
    @ps.killAll @_fullCmd, 'SIGHUP'

  getConfigFile: ->
    @_configFilePath ?= path.join config.configDir, @_configFile

  # Initialize config file if @configFile is present.
  initConfig: ->
    return Promise.resolve()  unless @_configFile
    # Copy default config file from cli/config/* if config is not present
    conf = @getConfigFile()
    utils.fs.exists conf
    .then (configExists) =>
      return true  if configExists
      src = path.join __dirname, '../config', @_configFile
      @log.debug '[ init ]'.grey, "Copying #{src} to #{conf}"
      utils.fs.mkdir config.configDir
      .then ->
        @ps.exec "cp #{src} #{conf}", timeout: 100
      .spread (stdout, stderr) =>
        @log.debug stderr  if stderr
    .then =>
      @_configFile = conf

  # todo: add log rotation or truncation somewhere
  # http://stackoverflow.com/questions/11403953/winston-how-to-rotate-logs
  initLogs: ->
    return Promise.resolve()  if @stdout and @stderr
    dir = path.join config.logDir, @_cmd
    @_logFiles.stdout = path.join dir, 'stdout.log'  unless @_logFiles.stdout
    @_logFiles.stderr = path.join dir, 'stderr.log'  unless @_logFiles.stderr
    utils.fs.mkdir dir
    .then =>
      Promise.join(
        fsOpen @_logFiles.stdout, 'a'
        fsOpen @_logFiles.stderr, 'a'
      ).then (fds) =>
        [@stdout, @stderr] = fds


module.exports = Process
