# VirtualMachine facade


class VirtualMachine

  isRunning: ->

  # Getters
  getState: ->
  getDockerIP: ->
  getDockerPort: ->

  # Returns promise
  info: ->
  up: ->
  status: ->

  @factory: (type) ->
    new (require "../plugins/#{type}")


module.exports = VirtualMachine
