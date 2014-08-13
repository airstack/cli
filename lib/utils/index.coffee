_ = require 'lodash'


module.exports =
  fs: require './fs'
  ps: require './process'
  string: require './string'

  ###*
  _.defaults with deep merge.
  @param {object} options
  @param {object} defaults
  Values from defaults are copied into options if not set in options.
  ###
  defaults: _.partialRight(_.merge, _.defaults)
