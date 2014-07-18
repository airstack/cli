_ = require 'lodash'

class Config
  constructor: (config) ->
    @_config = config
    @env = @_config.ENV.ENV || 'development'

  getContainerImage: ->
    # TODO: resolve semantic version and add version tag
    @_config.container.image

  # Iterate over config collections.
  # Example: config.forEach('ENV', (k, v) ->)
  forEach: (key, func) ->
    prop = @_config[key]
    method = if _.isObject(prop) then 'forIn' else 'forEach'
    _[method](prop, func)

  toString: ->
    JSON.stringify @_config, null, '  '

  # console.log calls inspect
  inspect: ->
    @toString()

module.exports = Config
