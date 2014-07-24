fs = require 'fs'
path = require 'path'

class Utils
  # Create nested directories as needed
  # Same as `mkdir -p`
  @mkdir: (dir, mode) ->
    dir = path.resolve dir
    if typeof mode == 'undefined'
      mode = 0o777 & (~process.umask())
    try
      unless fs.statSync(dir).isDirectory()
        throw new Error "#{dir} exists and is not a directory"
    catch err
      if err.code == 'ENOENT'
        @mkdir path.dirname(dir), mode
        fs.mkdirSync dir, mode
      else
        throw err

module.exports = Utils
