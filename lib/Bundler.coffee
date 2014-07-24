fs = require 'fs'
Tar = require 'tar-async'

class Bundler
  defaults:
    out: './.airstack/tmp/docker.tar'

  constructor: (outFilename = @defaults.out) ->
    @tape = new Tar output: fs.createWriteStream outFilename

  append: (filename, contents, opts, callback) ->
    @tape.append filename, contents, opts, callback

  close: ->
    @tape.close()

module.exports = Bundler
