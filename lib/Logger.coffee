winston = require 'winston'

###*
Centralized logger.

Use Logger instead of console.

Logger.Logger can be used to create a new instance if needed.
###
class Logger
  Logger: @constructor

  # Enable logs for levels <= level
  level: 'debug'

  levels:
    trace: 0
    debug: 1
    verbose: 2
    data: 2
    info: 3
    warn: 4
    error: 5

  colors:
    trace: 'magenta'
    verbose: 'cyan'
    data: 'grey'
    debug: 'blue'
    info: 'green'
    warn: 'white'
    error: 'red'

  constructor: ->
    @log = new winston.Logger
      levels: @levels
      colors: @colors
      transports: [
        new winston.transports.Console
          level: @level
          prettyPrint: true
          colorize: true
          silent: false
          timestamp: false
      ]

  setLevel: (level) ->
    @level = level
    @log.transports.console.level = level

  debug: ->
    @log.debug.apply null, arguments

  data: ->
    @log.data.apply null, arguments

  info: ->
    @log.info.apply null, arguments

  warn: ->
    @log.warn.apply null, arguments

  error: ->
    @log.error.apply null, arguments

  log: ->
    @log.log.apply null, arguments

# singleton
module.exports = new Logger
