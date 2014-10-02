yaml = require 'js-yaml'
eco = require 'eco'
Promise = require 'bluebird'
readFile = Promise.promisify require('fs').readFile
path = require 'path'
log = require './Logger'

ConfigParser =
  defaults:
    encoding: 'utf8'

  load: (file, encoding) ->
    @_loadFile(file, encoding)
    .then (contents) =>
      yaml.safeLoad @parse contents

  _loadFile: (file, encoding = @defaults.encoding) ->
    readFile path.normalize(file), encoding

  parse: (template, data = {}) ->
    eco.render template, data


module.exports = ConfigParser
