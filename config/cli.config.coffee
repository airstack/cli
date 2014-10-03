
# TODO: output command help on `airstack --help`; probably requires forking cli
module.exports =
  commands: [
    'up'
    'down'
    'build'
    'build-all'
    'console'
  ]

  options: {
    env: [false, 'Environment tag in airstack.yaml', 'string', 'development']
  }
