Promise = require 'bluebird'
spawn = require('child_process').spawn
exec = Promise.promisify require('child_process').exec
log = require '../Logger'
path = require 'path'
_ = require 'lodash'


module.exports =
  ###*
  @param {Array} cmds  Array of string or array commands.
                       String commands will use process.exec.
                       Array commands will use process.spawn.
  ###
  # runCmds: (cmds, opts = {}) ->
  #   _.defaults opts,
  #     sequential: false
  #     timeout: 1000
  #   execFunc = (cmd) =>
  #     if _.isArray cmd
  #       @spawn.apply @, arguments
  #     else
  #       @exec.apply @, arguments
  #   if sequential
  #     execFunc cmds.shift(), opts
  #     .then =>
  #       @runCmds cmds, opts
  #   else
  #     pcmds = for c in cmds
  #       execFunc c, opts
  #     Promise.all pcmds

  _execDefaults: (cmd, opts) ->
    # remove spaces from cmd and extract the bin name
    cmd = cmd.replace(/\/(.+?)\s+(.+?)\//g, '/$1$2/')
    cmd = cmd.split(' ')[0].split(path.sep).slice(-1)[0]
    debug = (type, msg) ->
      log.debug type, msg.toString().trim()  if msg
      msg
    _.defaults opts,
      data: debug.bind null, "#{cmd} stdout >>".grey
      error: debug.bind null, '#{cmd} stderr >>'.grey
      timeout: 1000

  ###*
  @return Promise
  Usage:
  exec(cmd, opts).spread (stdout, stderr) ->
  ###
  exec: (cmd, opts = {}) ->
    @_execDefaults cmd, opts
    log.debug "[exec]".grey, cmd
    exec cmd, opts
    .spread (stdout, stderr) ->
      opts.data stdout
      opts.error stderr
      [stdout, stderr]

  ###*
  @param {mixed} cmd  String cmd or Array of [cmd, args]
  @return {Number}    Process ID
  ###
  spawn: (cmd, args = [], opts = {}) ->
    if _.isArray cmd
      opts = args
      args = cmd[1]
      cmd = cmd[0]
    @_execDefaults cmd, opts
    _data = ''
    _error = ''
    # todo: use cancellable and timeout
    new Promise (resolve, reject) ->
      log.debug "[spawn]".grey, "#{cmd} #{args.join ' '}"
      proc = spawn cmd, args, opts
      if opts.detached
        pid = proc.pid
        proc.unref()
        resolve pid: pid
      else
        proc.stdout.on 'data', (data) ->
          _data += opts.data data
        proc.stderr.on 'data', (data) ->
          _error += opts.error data
        proc.on 'exit', (code) ->
          if code is 0
            resolve data: _data, error: _error, code: code
          else
            reject data: _data, error: _error, code: code

  # Use with spawn streams to handle output
  output:
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


  # @return {Array}  pids
  pgrep: (cmd, opts = {}) ->
    _.defaults opts,
      timeout: 100
      oldest: false
      data: @output.silent
    flags = if opts.oldest then '-o' else ''
    @exec "pgrep #{flags} -d ',' -f #{cmd}", opts
    .spread (stdout, stderr) =>
      pids = stdout.trim().split(',').map (pid) ->
        parseInt pid
      _.compact pids
    .catch (err) ->
      # pgrep returns 1 when process is not found
      if err.cause and err.cause.code is 1
        Promise.resolve []
      else
        log.error '[pgrep]'.grey, err
        Promise.reject err


  kill: (pid, signal = 'SIGTERM') ->
    if pid
      log.debug '[kill]'.grey, "Sending #{signal} to #{pid}"
      process.kill pid, signal


  killAll: (cmd, signal = 'SIGTERM', opts = {}) ->
    @pgrep cmd, opts
    .then (pids) =>
      @kill pid, signal for pid in pids


  stats: (cmd) ->
    # todo: implement
    # ps -A -c -o pid,%cpu,%mem,rss,time,etime,command | awk 'NR == 1 || /[V]Box/' | sed -e 's/^ *//' -e 's/[ ]\{1,\}/,/g'

