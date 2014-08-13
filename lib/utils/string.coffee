
module.exports =

  ###*
  Get random string.
  ###
  random: (length, chars = '0123456789abcdefghiklmnopqrstuvwxyz') ->
    charsLen = chars.length
    (for i in [1..length]
      chars.substr Math.floor(Math.random() * charsLen), 1
    ).join ''



  ###*
  Escape a string for use in regex.
  ###
  escapeRegExp: (str) ->
    str.replace /[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&'

