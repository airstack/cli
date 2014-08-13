Promise = require 'bluebird'
fs = Promise.promisifyAll require('fs')
path = require 'path'
os = require 'os'
_ = require 'lodash'
randomString = require('./string').random


module.exports =
  _tmpDir: path.join os.tmpdir(), '.airstack'

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
  fs.exists with Promise support.
  ###
  exists: (path) ->
    new Promise (resolve, reject) ->
      fs.exists path, resolve


  ###*
  Get a random file name in the OS's tmp dir.

  Does not guarantee uniqueness.
  ###
  randomTmpFile: (filename) ->
    filename = randomString 10  unless filename
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
    path.join @_tmpDir, dir, randomString 5
