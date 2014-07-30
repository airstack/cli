# Bundles files into a tarball.
#
# Useful for creating a tarball to send to the Docker API.

fs = require 'fs'
Tar = require 'tar-async'
config = require './Config'
Utils = require './Utils'
path = require 'path'

class Bundler
  defaults:
    tarFile: 'docker.tar'

  # todo: refactor with promises instead of sync mkdir
  constructor: (tarFile = @defaults.tarFile) ->
    @_tarFile = path.join config.getTmpDir(), tarFile
    Utils.mkdirSync path.dirname @_tarFile
    @_tape = new Tar output: fs.createWriteStream @_tarFile

  getFile: ->
    @_tarFile

  append: (filename, contents, opts, callback) ->
    @_tape.append filename, contents, opts, callback

  close: (callback) ->
    @_tape.once 'end', ->
      # HACK: tar-async.close does not close the stream in time
      setTimeout callback, 100
    @_tape.close()

module.exports = Bundler
