# Bundles files into a tarball.
#
# Useful for creating a tarball to send to the Docker API.

fs = require 'fs'
Tar = require 'tar-async'
Utils = require './Utils'
path = require 'path'

class Bundler
  defaults:
    out: './.airstack/tmp/docker.tar'

  constructor: (tarFile = @defaults.out) ->
    @_tarFile = tarFile
    Utils.mkdirSync path.dirname @_tarFile
    @_tape = new Tar output: fs.createWriteStream @_tarFile

  append: (filename, contents, opts, callback) ->
    @_tape.append filename, contents, opts, callback

  close: (callback) ->
    @_tape.once 'end', ->
      # HACK: tar-async.close does not close the stream in time
      setTimeout callback, 100
    @_tape.close()

module.exports = Bundler
