yaml = require 'js-yaml'
fs = require 'fs'
path = require 'path'


class Parser
  defaults:
    encoding: 'utf8'

  load: (file, encoding = @defaults.encoding) ->
    file = path.normalize(file)
    contents = fs.readFileSync file, encoding
    yaml.safeLoad contents

# singleton
module.exports = new Parser
