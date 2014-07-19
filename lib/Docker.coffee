Docker = require 'dockerode'
spawn = require('child_process').spawn

docker = new Docker host: 'http://192.168.1.10', port: 3000

# use https://www.npmjs.org/package/dockops ???

class Docker
  cmd:
    start: ['boot2docker', ['up']]
    status: ['boot2docker', ['status']]

  constructor: (dockerfile) ->
    @_dockerfile = dockerfile

  init: (callback) ->
    # TODO: use promises instead of callbacks
    status = spawn.apply null, @cmd.status
    running = false
    status.stdout.on 'data', (data) ->
      if "#{data}".trim() == 'running'
        running = true
    status.on 'exit', (code) =>
      if running
        callback()
      else
        @startVM callback

  startVM: (callback) ->
    console.log '[STARTING VM]'
    start = spawn.apply null, @cmd.start
    start.stdout.on 'data', (data) ->
      process.stdout.write data.toString()
    start.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    start.on 'exit', (code) =>
      callback()


module.exports = Docker
