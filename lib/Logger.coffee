winston = require 'winston'

###*
Centralized logger.

Use Logger instead of console.

Logger.Logger can be used to create a new instance if needed.
###
class Logger
  Logger: @constructor

  # Enable logs for levels <= level
  level: 1 # debug

  # npm style levels
  levels:
    silly: 0
    debug: 1
    verbose: 2
    data: 2
    info: 3
    warn: 4
    error: 5

  colors:
    silly: 'magenta'
    verbose: 'cyan'
    data: 'grey'
    debug: 'blue'
    info: 'green'
    warn: 'yellow'
    error: 'red'

  constructor: ->
    @log = new winston.Logger
      levels: @levels
      transports: [
        new  winston.transports.Console
      ]
    @log.cli()
    winston.addColors @colors

  setLevel: (level) ->
    @level = @levels[level]

  debug: ->
    @log.info.apply null, arguments  if @level <= @levels['debug']

  data: ->
    @log.data.apply null, arguments  if @level <= @levels['data']

  info: ->
    @log.info.apply null, arguments  if @level <= @levels['info']

  warn: ->
    @log.warn.apply null, arguments  if @level <= @levels['warn']

  error: ->
    @log.error.apply null, arguments  if @level <= @levels['error']

  log: ->
    @log.log.apply null, arguments  if @level <= @levels[arguments[0]]

# singleton
module.exports = new Logger
