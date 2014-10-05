_ = require 'lodash'
_.defaults = require('../lib/utils/object').deepDefaults
Ps = require '../lib/Ps'
path = require 'path'

class Make
  constructor: (opts) ->
    {@app} = opts
    @ps = new Ps app: @app

  make: (target, config, opts = {}) ->
    args = [
      "-f"
      "#{path.join config.paths.airstack.bootstrap, 'Makefile'}"
      target
    ]
    _.defaults opts,
      env: @env config
      stdout: (data) ->
        process.stdout.write data
      stderr: (data) ->
        process.stderr.write data
    @app.log.debug 'make env:', opts
    @ps.spawn 'make', args, opts

  env: (config) ->
    DEBUG_LEVEL: 2
    HOME: process.env.HOME
    PATH: process.env.PATH
    PWD: process.env.PWD
    AIRSTACK_HOME: config.paths.airstack.home
    AIRSTACK_ENV: config.environment
    AIRSTACK_MAKEFILE: config.build.makefile
    AIRSTACK_IMAGE_NAME: config.name
    AIRSTACK_BUILD_TEMPLATES_DIR: config.build.templates._cacheDir or config.build.templates.dir
    AIRSTACK_BUILD_TEMPLATES_FILES: config.build.templates.files
    AIRSTACK_BUILD_DIR: config.build.dir
    TERM: 'printf "EXEC::%s" '


module.exports = Make
