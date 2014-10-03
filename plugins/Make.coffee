log = require '../lib/Logger'
_ = require 'lodash'
_.defaults = require('../lib/utils/object').deepDefaults
spawn = require('../lib/utils/process').spawn
path = require 'path'

class Make
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
    log.debug 'make env:', opts
    spawn 'make', args, opts

  env: (config) ->
    HOME: process.env.HOME
    PATH: process.env.PATH
    PWD: process.env.PWD
    AIRSTACK_HOME: config.paths.airstack.home
    AIRSTACK_ENV: config.environment
    AIRSTACK_MAKEFILE: config.build.makefile
    AIRSTACK_IMAGE_NAME: config.name
    AIRSTACK_BUILD_TEMPLATES_DIR: config.build.templates.dir
    AIRSTACK_BUILD_TEMPLATES_FILES: config.build.templates.files
    DEBUG_LEVEL: 2
    TERM: 'printf "EXEC::%s" '


module.exports = Make
