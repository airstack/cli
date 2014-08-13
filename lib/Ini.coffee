utils = require './utils'


class Ini
  constructor: (iniData) ->
    @_ini = iniData

  replaceSection: (section, data) ->
    safe = utils.string.escapeRegExp section
    r = new RegExp "^\s*\[#{safe}\]\s*$\s(\s*^\s*[^\[\s].*$)*", 'gm'
    @_ini = @_ini.replace r, ''
    @_ini += "\n#{data}\n"

  toString: ->
    @_ini


module.exports = Ini
