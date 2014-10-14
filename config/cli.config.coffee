
# TODO: output command help on `airstack --help`; probably requires forking cli
module.exports =
  commands: [
    'up'
    'down'
    'build'
    'build-all'
    'console'
    'clean'
    'clean-all'
    'test'
    'config'
    'run'
    'shell'
  ]

  options: {
    env: [false, 'Environment tag in airstack.yml', 'string', 'development']
  }
