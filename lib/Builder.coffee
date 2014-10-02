Make = require '../plugins/Make'
log = require './Logger'
# Promise = require 'bluebird'
# readFile = Promise.promisify require('fs').readFile
_ = require 'lodash'


class Builder
  constructor: (opts) ->
    {@config} = opts
    @make = new Make config: @config

  build: ->
    log.error 'config', @config
    @make.make 'build-image'

  # buildfile: (file, encoding = 'utf8') ->
  #   unless file
  #     file = config.buildFile
  #     encoding = config.buildFileEncoding
  #   readFile path.normalize(file), encoding
  #   .then (contents) =>
  #     contents = @_setFrom contents
  #     contents = @_setEnv contents
  #     contents

  _setFrom: (contents) ->
    console.log "!!!!!! #{config.imageFrom}"
    if config.imageFrom
      contents.replace /^FROM\s.*/g, "FROM #{config.imageFrom}"
    contents

  # Add ENV vars to buildfile contents
  _setEnv: (contents) ->
    # Set meta env vars
    # https://github.com/airstack/docs/blob/master/README.md#environment-variables
    envFunc = (v, k) ->
      contents += "ENV #{k} \"#{v}\"\n"
    config.forEach 'ENV', envFunc
    env =
      COMPONENT_NAME: config.name
    _.forIn env, envFunc
    contents



module.exports = Builder
