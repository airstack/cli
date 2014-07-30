# Bundles files into a tarball.
#
# Useful for creating a tarball to send to the Docker API.

fs = require 'fs'
Tar = require 'tar-async'
config = require './Config'
Utils = require './Utils'
Promise = require 'bluebird'
path = require 'path'

class Bundler
  defaults:
    tarFile: 'docker.tar'

  constructor: (tarFile = @defaults.tarFile) ->
    @_tarFile = path.join config.getTmpDir(), tarFile
    @_tape = null

  getFile: ->
    @_tarFile

  init: ->
    return Promise.resolve()  if @_tape
    Utils.mkdir path.dirname @_tarFile
    .then =>
      @_tape = new Tar output: fs.createWriteStream @_tarFile

  append: (filename, contents, opts, callback) ->
    @init()
    .then =>
      @_tape.append filename, contents, opts, callback

  close: (callback) ->
    @_tape.once 'end', ->
      # HACK: tar-async.close does not close the stream in time
      setTimeout callback, 100
    @_tape.close()

module.exports = Bundler
