EventEmitter = require 'eventemitter3'

###*
# App state container and event emitter.
#
# API:
# _config  Config instance
# config   Current confing environment context; i.e. _config.config
# vm       VirtualMachine instance used to send commands to VM
# cli      CLI instance used to get args and options
# log      Logger instance
###
class AppState extends EventEmitter
  constructor: (opts) ->
    {@_config, @vm, @cli, @log} = opts

  Object.defineProperties @prototype,
    config:
      get: -> @_config.config


module.exports = AppState
