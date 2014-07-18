cli = require './Cli'
parser = require './Parser'
Config = require './Config'
Builder = require './Builder'


console.log "Command is: #{cli.command()}"

try
  yml = parser.load '.airstack.yml'
  config = new Config yml
  console.log config
  builder = new Builder config
  builder.buildfile()
catch e
  console.error e
