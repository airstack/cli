Dockerode = require 'dockerode'
_ = require 'lodash'

class Docker
  constructor: (opts) ->
    @_docker = new Dockerode opts

  # opts: options object or imageName string
  build: (tarfile, opts, callback) ->
    if _.isString opts
      opts =
        t: opts
    @_docker.buildImage tarfile, opts, callback


module.exports = Docker
