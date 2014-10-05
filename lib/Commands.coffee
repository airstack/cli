# Builder = require './Builder'
# Docker = require './Docker'
Make = require '../plugins/Make'
eco = require 'eco'
Promise = require 'bluebird'
Samba = require '../plugins/Samba'
path = require 'path'
readFile = Promise.promisify require('fs').readFile
writeFile = Promise.promisify require('fs').writeFile
mkdir = require('./utils/fs').mkdir
util = require 'util'

class Commands
  # boot2docker info object
  info: {}
  # boot2docker host ip
  ip: null

  constructor: (opts) ->
    {@app} = opts
    @log = @app.log
    @vm = @app.vm
    @make = new Make app: @app

  # Getters/Setters
  Object.defineProperties @prototype,
    samba:
      get: -> @_samba ?= new Samba app: @app


  up: ->
    Promise.all [
      @samba.up()
      @vm.up()
    ]
    .then =>
      Promise.all [
        @samba.mount()
        @build()
      ]
    .then =>
      @run()

  down: ->
    Promise.all [
      @samba.kill()
      @vm.down()
    ]
    .then =>
      @log.info '[ DONE ]'.grey

  build: (config = @app.config) ->
    @log.debug 'build config:', config
    @buildCache config
    .then =>
      @make.make 'build', config

  buildCache: (config = @app.config) ->
    cacheDir = path.join config.build.cache, config.build.templates.dir
    config.build.templates._cacheDir = cacheDir
    mkdir cacheDir, 0o755
    .then =>
      files = for fileName in config.build.templates.files.split ' '
        @buildCacheFile fileName, cacheDir, config
      Promise.all files

  buildCacheFile: (fileName, cacheDir, config = @app.config) ->
    readFile path.join(config.build.templates.dir, fileName), 'utf8'
    .then (tpl) ->
      tpl = eco.render tpl, config: config
      writeFile path.join(cacheDir, fileName), tpl, encoding: 'utf8', mode: 0o666

  build_all: ->
    @all 'build'

  clean: (config = @app.config) ->
    @make.make 'clean', config

  clean_all: ->
    @all 'clean'

  test: (config = @app.config) ->
    @make.make 'test', config
    .then =>
      @app.emit 'exit', code: 2

  all: (cmd) ->
    Promise.all (@[cmd] config for k,config of @app._config.environments)

  console: ->
    @make.make 'console', @app.config
    .then =>
      @app.emit 'exit', code: 2

  run: ->
    # @docker.run()

  cleanup: ->
    @samba.kill()
    # @docker.cleanup()
    # IDEA: instead of specific cleanup calls, use "stop" event.
    #   A process responding to a stop event should remove itself as a listener when it's done.
    #   Exit after all stop listeners have been removed.
    #   Pros: keeps code more modular
    #   Cons: harder to control order of stop events if needed

    # Optimization: spawn a process that does the cleanup steps; useful for immediate exit; does this break unix philosophy?

module.exports = Commands


