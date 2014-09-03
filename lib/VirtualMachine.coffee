# VirtualMachine facade


class VirtualMachine
  # Getters
  running: null
  state: null
  dockerIP: null
  dockerPort: null

  # Functions
  # @return Promise
  info: ->
  up: ->
  status: ->

  @factory: (type) ->
    new (require "../plugins/#{type}")


module.exports = VirtualMachine
