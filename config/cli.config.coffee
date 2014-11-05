
# TODO: output command help on `airstack --help`; probably requires forking cli
module.exports =
  commands: [
    'up'
    'down'
    'build'
    'build-all'
    'build-cache'
    'console'
    'clean'
    'clean-all'
    'test'
    'config'
    'run'
    'shell'
    'cli-edit'
    'cli-update'
  ]

  options: {
    env: [false, 'Environment tag in airstack.yml', 'string', 'development']
  }
