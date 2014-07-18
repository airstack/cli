cli = require './Cli'
parser = require './Parser'
Config = require './Config'


console.log "Command is: #{cli.command()}"

try
  yml = parser.load '.airstack.yml'
  config = new Config yml
  console.log config
catch e
  console.error e
