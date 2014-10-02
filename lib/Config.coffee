log = require './Logger'
utils = require './utils'
os = require 'os'
path = require 'path'
_ = require 'lodash'
_.defaults = require('./utils/object').deepDefaults
uuid = require 'node-uuid'

AIRSTACK_HOME = process.env.AIRSTACK_HOME
unless AIRSTACK_HOME
  # HOMEPATH and USERPROFILE are win32
  AIRSTACK_HOME = path.join process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE, '.airstack'


class Config
  # Current environment name: development, test, etc.
  environment: null

  _defaults:
    paths:
      airstack:
        home: AIRSTACK_HOME
        log: 'log'
        data: 'data'
        # Create random dir inside of OS tmp dir
        tmp: utils.fs.randomTmpDir()
        # Set config path to absolute path in case base is changed.
        # It's best if config files are universal for an Airstack install.
        # Only one of Samba, VirtualBox, etc. can be running at a time.
        config: 'config'
        # Default location to mount dirs in container if not specified in mount
        mount: '/home/airstack/mount/'
        bootstrap: 'package/airstack/bootstrap/'

  constructor: ->
    @reset()

  init: (config = {}, environment) ->
    @_config = _.cloneDeep config
    for k,v of @_config
      continue unless k[0] is ':'
      e = k.slice(1)
      v.environment = e
      @_environments[e] = v
      delete @_config[k]
    _.defaults @_config, @_defaults
    @_initPaths @_config.paths
    for k,v of @_environments
      @_initPaths v.paths  if v.paths?
      _.defaults v, @_config
    @_config.environment = environment
    @config = @_environments[environment] or @_config
    log.error '!!!! config:', @config
    @config

    unless @config.name?
      throw 'Invalid config: name must be defined'

  _initPaths: (paths) ->
    home = paths.airstack.home
    for k,v of paths.airstack
      paths.airstack[k] = path.resolve home, v

  _initMounts: ->
    @_mounts = for m in @config.mount
      [fromPath, toPath] = m.split ':'
      # Convert absolute paths; this really should not be needed
      name = path.relative process.cwd(), fromPath
      # Strip parent directories and normalize path
      name = path.normalize name.replace(/\.\./g, '')
      name = _.compact name.split path.sep
      name = if name.length then "__#{name.join '-'}" else ''
      {
        name: "#{@config.name}_#{@uuid}#{name}"
        from: fromPath
        to: toPath or "#{@config.paths.airstack.mount}#{name}"
      }

  reset: ->
    @_config = {}
    @_environments = {}
    @uuid = uuid.v1()

  # Iterate over config collections.
  # Example: config.forEach('ENV', (k, v) ->)
  forEach: (key, func) ->
    prop = @config[key]
    method = if _.isObject(prop) then 'forIn' else 'forEach'
    _[method](prop, func)

  toString: (padding) ->
    JSON.stringify @config, null, padding

  # console.log calls inspect
  inspect: ->
    @toString '  '

module.exports = Config
