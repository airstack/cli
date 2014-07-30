fs = require 'fs'
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
  Synchronously create specified directory.

  Creates parent directories as needed. Same as `mkdir -p`
  ###
  mkdirSync: (dir, mode) ->
    dir = path.resolve dir
    if typeof mode == 'undefined'
      mode = 0o777 & (~process.umask())
    try
      unless fs.statSync(dir).isDirectory()
        throw new Error "#{dir} exists and is not a directory"
    catch err
      if err.code == 'ENOENT'
        @mkdirSync path.dirname(dir), mode
        fs.mkdirSync dir, mode
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
