log = require './Logger'
utils = require './utils'
os = require 'os'
path = require 'path'
_ = require 'lodash'
uuid = require 'node-uuid'

# HOMEPATH and USERPROFILE are win32
HOMEDIR = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE

INSTALLDIR = path.join HOMEDIR, '.airstack'


class Config
  _defaults:
    name: 'app'
    container:
      encoding: 'utf8'
    scripts: {}
    components: []
    ENV:
      APP_ENV: 'development'
    # Paths are relative to paths.base or absolute
    paths:
      base: INSTALLDIR
      log: 'log'
      data: 'data'
      # Create random dir inside of OS tmp dir
      tmp: utils.fs.randomTmpDir()
      # Set config path to absolute path in case base is changed.
      # It's best if config files are universal for an Airstack install.
      # Only one of Samba, VirtualBox, etc. can be running at a time.
      config: path.join INSTALLDIR, 'config'

  constructor: ->
    @_config = @_defaults
    @uuid = uuid.v1()

  init: (config = {}) ->
    clone = _.cloneDeep config
    utils.defaults clone, @_defaults
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

  getMounts: ->
    @_config.mount

  getENV: ->
    @_config.ENV.APP_ENV

  getContainerImage: ->
    # TODO: resolve semantic version and add version tag
    @_config.container.image

  getTmpDir: (app = '') ->
    @getDir 'tmp', app

  getLogDir: (app = '') ->
    @getDir 'log', app

  getDataDir: (app = '') ->
    @getDir 'data', app

  getConfigDir: ->
    @getDir 'config'

  getConfigFile: (file) ->
    path.join @getConfigDir(), file

  getDir: (pathname, app = '') ->
    path.resolve @_config.paths.base, @_config.paths[pathname], app

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
