cli = require './Cli'
parser = require './Parser'
Config = require './Config'
Builder = require './Builder'
VirtualMachine = require './VirtualMachine'


console.log "Command is: #{cli.command()}"

try
  yml = parser.load '.airstack.yml'
catch e
  console.log '[ERROR]'
  console.error e

config = new Config yml
console.log config
builder = new Builder config
dockerfile = builder.buildfile()
vm = new VirtualMachine
vm.info (info) ->
  console.log '[INFO]'
  console.log info
  todo()



todo = ->
  console.log "\n\n\n-----------------------"
  console.log "TODO:"
  console.log "  - bundle Dockerfile into tar"
  console.log "  - send tar to docker"
  console.log "  - send cmd to docker"
  console.log "  - use dockerops npm package???"

