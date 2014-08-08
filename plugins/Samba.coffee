# See https://github.com/airstack/docs/blob/master/samba.md

Process = require '../lib/Process'
config = require '../lib/Config'

class Samba extends Process
  _detached: true
  _cmdPath: '/usr/local/Cellar/samba/3.6.23/sbin/'
  _cmd: 'smbd'
  # Run in interactive mode since node is piping stdout and stderr to files
  # http://www.samba.org/samba/docs/man/manpages/smbd.8.html
  _args: ['-F', '-S', '--no-process-group', '--debuglevel=1', '--port=9000']


module.exports = Samba
