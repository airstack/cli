Table = require 'cli-table'

class StatusTable
  constructor: ->
    @table = new Table
      head: ['App name', 'id',   'mode', 'PID',  'status', 'restarted', 'uptime', 'memory', 'watching']
      colAligns: ['left', 'left', 'left', 'left', 'left', 'right', 'left', 'right', 'right']
      style:
        'padding-left': 1
        head: ['cyan', 'bold']
        border: ['white']
        compact : true

  render: (data) ->
    @table.length = 0
    for row in data
      @table.push row
    @table.toString()

module.exports = StatusTable
