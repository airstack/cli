# Bundles files into a tarball.
#
# Useful for creating a tarball to send to the Docker API.

fs = require 'fs'
Tar = require 'tar-async'
config = require './Config'
utils = require './utils'
Promise = require 'bluebird'
path = require 'path'


class Bundler
  defaults:
    tarFile: "docker_#{(new Date).getTime()}_#{utils.string.random 5}.tar"

  constructor: ->
    @_tarFile = path.join config.getTmpDir(), @defaults.tarFile
    @_tape = null

  getFile: ->
    @_tarFile

  init: ->
    return Promise.resolve()  if @_tape
    utils.fs.mkdir path.dirname @_tarFile
    .then =>
      @_tape = new Tar output: fs.createWriteStream @_tarFile

  append: (filename, contents, opts) ->
    @init()
    .then =>
      @_tape.append filename, contents, opts, (ret) ->
        Promise.resolve ret

  close: ->
    new Promise (resolve, reject) =>
      @_tape.once 'end', ->
        # HACK: tar-async.close does not close the stream in time
        setTimeout ->
          resolve true
        , 100
      @_tape.close()

module.exports = Bundler
