fs = require 'fs'
Tar = require 'tar-async'
Utils = require './Utils'
path = require 'path'

class Bundler
  defaults:
    out: './.airstack/tmp/docker.tar'

  constructor: (tarFile = @defaults.out) ->
    @tarFile = tarFile
    Utils.mkdir path.dirname @tarFile
    @tape = new Tar output: fs.createWriteStream @tarFile

  append: (filename, contents, opts, callback) ->
    @tape.append filename, contents, opts, callback

  close: ->
    @tape.close()

module.exports = Bundler
