config = require './Config'
fs = require 'fs'
path = require 'path'
_ = require 'lodash'

class Builder

  buildfile: (file, encoding = 'utf8') ->
    # TODO: add support for concatenating build dir, if dir given
    unless file
      [file, encoding] = config.getBuildFile()
    # TODO: use promises
    contents = fs.readFileSync path.normalize(file), encoding
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
