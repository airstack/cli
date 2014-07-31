config = require './Config'
Promise = require 'bluebird'
readFile = Promise.promisify require('fs').readFile
fs = require 'fs'
path = require 'path'
_ = require 'lodash'

class Builder

  buildfile: (file, encoding = 'utf8') ->
    unless file
      [file, encoding] = config.getBuildFile()
    readFile path.normalize(file), encoding
    .then (contents) =>
      contents = @_setFrom contents
      contents = @_setEnv contents
      contents

  _setFrom: (contents) ->
    contents.replace /^FROM\s.*/g, "FROM #{config.getContainerImage()}"

  # Add ENV vars to buildfile contents
  _setEnv: (contents) ->
    # Set meta env vars
    # https://github.com/airstack/docs/blob/master/README.md#environment-variables
    env =
      COMPONENT_NAME: config.getName().toUpperCase()
    envFunc = (v, k) ->
      contents += "ENV #{k} \"#{v}\"\n"
    config.forEach 'ENV', envFunc
    _.forIn env, envFunc
    contents



module.exports = Builder
