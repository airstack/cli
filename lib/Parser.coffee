yaml = require 'js-yaml'
fs = require 'fs'
path = require 'path'

class Parser
  load: (file = '.airstack.yml', encoding = 'utf8') ->
    file = path.normalize(file)
    contents = fs.readFileSync file, encoding
    yaml.safeLoad contents

# singleton
module.exports = new Parser
