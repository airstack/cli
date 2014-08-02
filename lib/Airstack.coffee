config = require './Config'
cli = require './Cli'
log = require './Logger'
Parser = require './Parser'
Commands = require './Commands'
VirtualMachine = require './VirtualMachine'
Promise = require 'bluebird'


class Airstack
  configFile: '.airstack.yml'

  constructor: ->
    cmd = cli.command()
    log.debug 'Command:'.bold, cmd
    Promise.all [
      @loadConfig()
      @createVM()
    ]
    .then =>
      @run cmd

  loadConfig: ->
    Parser.loadYaml @configFile
    .then (yaml) =>
      config.init yaml

  run: (cmd) ->
    @cmd ?= new Commands vm: @vm
    opts = cli.opts()
    switch cmd
      when 'up' then @cmd.up opts
      when 'down' then @cmd.down opts
      else cli.help()

  createVM: ->
    # todo: parse config/<platform>.yml to get vm
    log.debug 'Using VirtualBox'
    @vm = VirtualMachine.factory 'VirtualBox'


module.exports = new Airstack
