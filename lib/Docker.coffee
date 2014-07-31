Dockerode = require 'dockerode'
log = require './Logger'
_ = require 'lodash'

class Docker
  constructor: (opts) ->
    @_docker = new Dockerode opts

  # opts: options object or imageName string
  build: (tarfile, opts) ->
    if _.isString opts
      opts =
        t: opts
    imageName = opts.t
    new Promise (resolve, reject) =>
      @_docker.buildImage tarfile, opts, (error, stream) ->
        return reject error  if error
        stream.on 'error', (data) ->
          log.error data
        stream.on 'data', (data) ->
          data = JSON.parse data
          if data.error
            error = data
          else
            for k, v of data
              log.debug v.toString().trim()
        stream.on 'end', ->
          if error
            log.error error
            reject error
          else
            log.info "Built image: #{imageName}"
            resolve()



module.exports = Docker
