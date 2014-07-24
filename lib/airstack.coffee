cli = require './Cli'
parser = require './Parser'
Config = require './Config'
Builder = require './Builder'
VirtualMachine = require './VirtualMachine'
Docker = require './Docker'

console.log "Command is: #{cli.command()}"

init = ->
  config = new Config yml
  console.log config
  builder = new Builder config
  dockerfile = builder.buildfile()
  vm = new VirtualMachine
  vm.info (info) ->
    console.log '[INFO]'
    console.log info
    vm.up ->
      vm.ip (ip) ->
        build ip, info
      todo()

# test build
build = (ip, info) ->
  # console.log "Using socket file: #{info.SerialFile}"
  # docker = new Docker socketPath: info.SerialFile

  imageName = 'testbuild'

  docker = new Docker host: "http://#{ip}", port: info.DockerPort
  docker.build './defaults/test.tar', imageName, (error, stream) ->
    return console.error error  if error
    stream.on 'error', (data) ->
      error = data.toString()
      process.stderr.write "[ERROR] #{error}"
    stream.on 'data', (data) ->
      data = JSON.parse(data)
      if data.error
        error = data
        console.log "\n[ERROR]"
        console.log data
      else
        for k, v of data
          tab = if k == 'status' then '  ' else ''
          process.stdout.write "#{tab}#{v.toString()}"
    stream.on 'end', ->
      console.log "Built image: #{imageName}" unless error

try
  yml = parser.load '.airstack.yml'
catch e
  console.log '[ERROR]'
  console.error e.message

init() if yml


# todo !!!!
# ...... WHEN I GET BACK ......
# 1. manually tar a Dockerfile
# 2. send tarfile to dockerode to see if it works
#    via the serialfile???
# 3. get tar-async working
# 4. write code to output init scripts and add them to Dockerfile

todo = ->
  console.log "\n\n\n-----------------------"
  console.log "TODO:"
  console.log "  - bundle Dockerfile into tar"
  console.log "  - send tar to docker"
  console.log "  - send cmd to docker"
  console.log "  - use dockerops npm package???"


