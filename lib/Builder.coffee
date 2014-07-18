_ = require 'lodash'
fs = require 'fs'
path = require 'path'

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
    console.log contents

  _setFrom: (contents) ->
    contents.replace /^FROM\s.*/g, "FROM #{@_config.getContainerImage()}"

  # Add ENV vars to buildfile contents
  _setEnv: (contents) ->
    @_config.forEach 'ENV', (v, k) ->
      contents += "ENV #{k} #{v}\n"
    contents


module.exports = Builder
