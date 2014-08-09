Utils = require './Utils'
os = require 'os'
path = require 'path'
_ = require 'lodash'

# HOMEPATH and USERPROFILE are win32
HOMEDIR = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE


class Config
  _defaults:
    name: 'app'
    container:
      build: "#{__dirname}/../defaults/Dockerfile"
      encoding: 'utf8'
    scripts: {}
    components: []
    ENV:
      APP_ENV: 'development'
    # Paths are relative to paths.base or absolute
    paths:
      base: path.join HOMEDIR, '.airstack'
      tmp: Utils.randomTmpDir()
      log: 'log'
      data: 'data'

  constructor: ->
    @_config = @_defaults

  init: (config = {}) ->
    clone = _.cloneDeep config
    Utils.defaults clone, @_defaults
    @_config = clone
    @normalizePaths()

  reset: ->
    @_config = @_defaults

  getName: ->
    @_config.name

  getBuildFile: ->
    {
      file: @_config.container.build
      encoding: @_config.container.encoding
      toString: ->
        @file
    }

  getENV: ->
    @_config.ENV.APP_ENV

  getContainerImage: ->
    # TODO: resolve semantic version and add version tag
    @_config.container.image

  getTmpDir: ->
    path.resolve @_config.paths.base, @_config.paths.tmp

  getLogDir: (app = '') ->
    path.resolve @_config.paths.base, @_config.paths.log, app

  getDataDir: (app = '') ->
    path.resolve @_config.paths.base, @_config.paths.data, app

  normalizePaths: ->
    base = @_config.paths.base
    if base[0] is '~'
      @_config.paths.base = path.join HOMEDIR, base.slice(1)

  # Iterate over config collections.
  # Example: config.forEach('ENV', (k, v) ->)
  forEach: (key, func) ->
    prop = @_config[key]
    method = if _.isObject(prop) then 'forIn' else 'forEach'
    _[method](prop, func)

  toString: (padding) ->
    JSON.stringify @_config, null, padding

  # console.log calls inspect
  inspect: ->
    @toString '  '

# singleton
module.exports = new Config
