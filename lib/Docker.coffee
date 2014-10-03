Promise = require 'bluebird'
Dockerode = require 'dockerode'
log = require './Logger'
config = require './Config'
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
            log.info 'Built image:', imageName
            resolve()

  run: ->
    # OSX_RUNFLAGS = --volume $(BOOT2DOCKER_DIR)/example:/home/airstack/example
    # COMMON_RUNFLAGS = --publish-all --workdir /home/$(USERNAME) --user $(USERNAME) --hostname=$(SHORTNAME)-$(VERSION) $(NAME):$(VERSION)
    # docker run --rm -i -t $(OSX_RUNFLAGS) $(COMMON_RUNFLAGS)
    image = config.containerImage
    log.info '[docker]'.grey, 'starting image:', image
    for mount in config.mounts
      log.data 'mount: ', mount
    return
    @_docker.run image, null, [process.stdout, process.stderr],  Tty: false, (err, data, container) ->
      log.info '!!!!!! container ended:', image
      # TODO: remove containers on stop
      #     use v=1
      # https://github.com/docker/docker/blob/ad7279e48053adfde3ba20a5c67e812a7ec677f6/api/client/commands.go#L2164
      # log.error 'error:', err
      # log.data 'data:', data
    .on 'container', (container) ->
      log.info '>>>>> container:', container
      # container.attach stream: true, stdout: true, stderr: true, (err, stream) ->
      #   stream.pipe process.stdout
        # API: https://docs.docker.com/reference/api/docker_remote_api_v1.13/
      # container.defaultOptions.start.Binds = ['/tmp:/tmp:rw']



module.exports = Docker
