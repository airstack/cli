Promise = require 'bluebird'
fs = Promise.promisifyAll require('fs')
path = require 'path'
os = require 'os'
_ = require 'lodash'


Utils =
  _tmpDir: path.join os.tmpdir(), '.airstack'

  ###*
  _.defaults with deep merge.

  @param {object} options
  @param {object} defaults

  Values from defaults are copied into options if not set in options.
  ###
  defaults: _.partialRight(_.merge, _.defaults)

  ###*
  Create specified directory.

  Creates parent directories as needed. Same as `mkdir -p`.
  @return {promise}
  ###
  mkdir: (dir, mode) ->
    dir = path.resolve dir
    if _.isUndefined mode
      mode = 0o777 & (~process.umask())
    fs.statAsync dir
    .then (stat) ->
      unless stat.isDirectory()
        throw "#{dir} exists and is not a directory"
      stat
    .catch (err) =>
      if err.cause.code is 'ENOENT'
        @mkdir path.dirname(dir), mode
        .then ->
          fs.mkdirAsync dir, mode
      else
        throw err


  ###*
  Get random string.
  ###
  randomString: (length, chars = '0123456789abcdefghiklmnopqrstuvwxyz') ->
    charsLen = chars.length
    (for i in [1..length]
      chars.substr Math.floor(Math.random() * charsLen), 1
    ).join ''


  ###*
  Get a random file name in the OS's tmp dir.

  Does not guarantee uniqueness.
  ###
  randomTmpFile: (filename) ->
    filename = @randomString 10  unless filename
    path.join os.tmpdir(), @randomTmpDir(), filename


  ###*
  Get random dir in OS's tmp dir.

  Does not guarantee uniqueness.
  ###
  randomTmpDir: ->
    dir = [
      'tmp-'
      process.pid
      '-'
      (Math.random() * 0x1000000000).toString 36
    ].join ''
    path.join @_tmpDir, dir, Utils.randomString 5


module.exports = Utils
