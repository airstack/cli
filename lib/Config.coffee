Utils = require './Utils'
os = require 'os'
path = require 'path'
_ = require 'lodash'




class Config
  _defaults:
    name: 'app'
    container:
      build: "#{__dirname}/../defaults/Dockerfile"
      encoding: 'utf8'
    scripts: {}
    components: []
    ENV:
      APP_ENV: 'development'
    tmpDir: null

  constructor: ->
    @_defaults.tmpDir = Utils.randomTmpDir()
    @_config = @_defaults

  init: (config = {}) ->
    clone = _.cloneDeep config
    Utils.defaults clone, @_defaults
    @_config = clone

  reset: ->
    @_config = @_defaults

  getName: ->
    @_config.name

  getBuildFile: ->
    [
      @_config.container.build
      @_config.container.encoding
    ]

  getENV: ->
    @_config.ENV.APP_ENV

  getContainerImage: ->
    # TODO: resolve semantic version and add version tag
    @_config.container.image

  getTmpDir: ->
    @_config.tmpDir

  # Iterate over config collections.
  # Example: config.forEach('ENV', (k, v) ->)
  forEach: (key, func) ->
    prop = @_config[key]
    method = if _.isObject(prop) then 'forIn' else 'forEach'
    _[method](prop, func)

  toString: (padding) ->
    JSON.stringify @_config, null, padding

  # console.log calls inspect
  inspect: ->
    @toString '  '

# singleton
module.exports = new Config
