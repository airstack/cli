yaml = require 'js-yaml'
Promise = require 'bluebird'
readFile = Promise.promisify require('fs').readFile
path = require 'path'


Parser =
  defaults:
    encoding: 'utf8'

  loadYaml: (file, encoding) ->
    @_loadFile(file, encoding).then (contents) ->
      yaml.safeLoad contents

  _loadFile: (file, encoding = @defaults.encoding) ->
    readFile path.normalize(file), encoding

module.exports = Parser
