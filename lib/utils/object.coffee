_ = require 'lodash'



recursiveMerge = ->
  # Ensure dates and arrays are not recursively merged
  return arguments[0]  if _.isArray(arguments[0]) or _.isDate(arguments[0])
  _.merge arguments[0], arguments[1], recursiveMerge


module.exports =
  ###*
  _.defaults with deep merge.

  Values from defaults are copied into options if not set in options.
  @param {object} options
  @param {object} defaults
  @see https://github.com/balderdashy/merge-defaults
  ###
  deepDefaults: _.partialRight _.merge, recursiveMerge


  ###*
  # Get/set the value of a nested property
  # https://gist.github.com/furf/3208381
  # Usage:
  #
  # var obj =
  #   a:
  #     b:
  #       c:
  #         d: ['e', 'f', 'g']
  #
  # Get deep value
  # deep(obj, 'a.b.c.d[2]'); // 'g'
  #
  # Set deep value
  # deep(obj, 'a.b.c.d[2]', 'george');
  #
  # deep(obj, 'a.b.c.d[2]'); // 'george'
  ###
  deep: (obj, key, value) ->
    keys = key.replace(/\[(["']?)([^\1]+?)\1?\]/g, '.$2').replace(/^\./, '').split('.')
    root = undefined
    i = 0
    n = keys.length

    # Set deep value
    if arguments.length > 2
      root = obj
      n--
      while i < n
        key = keys[i++]
        obj = obj[key] = (if _.isObject(obj[key]) then obj[key] else {})
      obj[keys[i]] = value
      value = root

    # Get deep value
    else
      continue  while (obj = obj[keys[i++]])? and i < n
      value = (if i < n then undefined else obj)
    value

