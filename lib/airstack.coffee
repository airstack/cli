cli = require './Cli'
parser = require './Parser'
Config = require './Config'
Builder = require './Builder'
Docker = require './Docker'


console.log "Command is: #{cli.command()}"

try
  yml = parser.load '.airstack.yml'
  config = new Config yml
  console.log config
  builder = new Builder config
  dockerfile = builder.buildfile()
  docker = new Docker dockerfile

  docker.init ->
    console.log "\n\n\n-----------------------"
    console.log "TODO:"
    console.log "  - bundle Dockerfile into tar"
    console.log "  - send tar to docker"
    console.log "  - send cmd to docker"
    console.log "  - use dockerops npm package???"
catch e
  console.error e
