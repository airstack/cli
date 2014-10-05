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

  @factory: (type, opts) ->
    new (require "../plugins/#{type}")(opts)


module.exports = VirtualMachine
