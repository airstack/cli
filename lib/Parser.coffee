yaml = require 'js-yaml'
fs   = require 'fs'

class Parser
  load: (fileName = '.airstack.yml', encoding = 'utf8') ->
    file = fs.readFileSync fileName, encoding
    yaml.safeLoad file

# singleton
module.exports = new Parser
