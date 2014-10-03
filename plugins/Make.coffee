log = require '../lib/Logger'
_ = require 'lodash'
_.defaults = require('../lib/utils/object').deepDefaults
spawn = require('../lib/utils/process').spawn
path = require 'path'

class Make
  constructor: (opts) ->
    {@config} = opts

  # Getters/Setters
  Object.defineProperties @prototype,
    env:
      get: ->
        env:
          HOME: process.env.HOME
          PATH: process.env.PATH
          PWD: process.env.PWD
          AIRSTACK_HOME: @config.paths.airstack.home
          AIRSTACK_ENV: @config.environment
          AIRSTACK_MAKEFILE: @config.build.makefile
          AIRSTACK_IMAGE_NAME: @config.name
          AIRSTACK_BUILD_TEMPLATES_DIR: @config.build.templates.dir
          AIRSTACK_BUILD_TEMPLATES_FILES: @config.build.templates.files
          DEBUG_LEVEL: 2

  make: (target, opts = {}) ->
    args = [
      "-f"
      "#{path.join @config.paths.airstack.bootstrap, 'Makefile'}"
      target
    ]
    _.defaults opts, @env
    log.debug 'make ENV:', opts
    spawn 'make', args, opts



module.exports = Make
