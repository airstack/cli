fs = require 'fs'
path = require 'path'
_ = require 'lodash'

class Builder
  defaults:
    buildfile: "#{__dirname}/../defaults/Dockerfile"
    encoding: 'utf8'

  constructor: (config) ->
    @_config = _.defaults config,
      container: {}
      scripts: {}
      components: []

  buildfile: (file) ->
    # TODO: add support for concatenating build dir, if dir given
    build = file || @_config.container.build || @defaults.buildfile
    build = path.normalize(build)
    contents = fs.readFileSync build, @defaults.encoding
    contents = @_setFrom contents
    contents = @_setEnv contents

    console.log "\n\n------------------\n# Dockerfile\n"
    console.log contents
    console.log "------------------\n\n"

    contents

  _setFrom: (contents) ->
    contents.replace /^FROM\s.*/g, "FROM #{@_config.getContainerImage()}"

  # Add ENV vars to buildfile contents
  _setEnv: (contents) ->
    # Set meta env vars
    # https://github.com/airstack/docs/blob/master/README.md#environment-variables
    env =
      COMPONENT_NAME: @_config.getName(true)
    envFunc = (v, k) ->
      contents += "ENV #{k} #{v}\n"
    @_config.forEach 'ENV', envFunc
    _.forIn env, envFunc
    contents



module.exports = Builder
