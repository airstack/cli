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
    @logger = new winston.Logger
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
    @logger.transports.console.level = level

  debug: ->
    @logger.debug.apply @logger, arguments

  data: ->
    @logger.data.apply @logger, arguments

  info: ->
    @logger.info.apply @logger, arguments

  warn: ->
    @logger.warn.apply @logger, arguments

  error: ->
    @logger.error.apply @logger, arguments

  log: (level) ->
    @logger.log.apply @logger, arguments

# singleton
module.exports = new Logger
