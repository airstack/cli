
class Config
  constructor: (config) ->
    @_config = config

  toString: ->
    JSON.stringify @_config, null, '  '

  # console.log calls inspect
  inspect: ->
    @toString()

module.exports = Config
