config = require '../lib/Config'
Utils = require '../lib/Utils'
expect = require('./helpers/Common').expect


describe 'Config', ->
  beforeEach ->
    config.reset()

  describe '.init', ->
    it 'defaults to development APP_ENV', ->
      expect( config.getENV() ).to.equal 'development'
      opts =
        ENV:
          SOME_ENV: 1
      config.init opts
      # Test to make sure ENV is not globbering defaults
      expect( config.getENV() ).to.equal 'development'

    it 'uses APP_ENV for getENV', ->
      opts =
        ENV:
          APP_ENV: 'production'
      config.init opts
      expect( config.getENV() ).to.equal 'production'

  describe '.getBuildFile', ->
    it 'uses container.build', ->
      opts =
        container:
          build: '/some/path/to/Dockerfile'
          encoding: 'ascii'
      config.init opts
      [file, encoding] = config.getBuildFile()
      expect( file ).to.equal opts.container.build
      expect( encoding ).to.equal opts.container.encoding

    it 'uses default container.build', ->
      config.init {}
      [file, encoding] = config.getBuildFile()
      expect( file ).to.equal config._defaults.container.build
      expect( encoding ).to.equal config._defaults.container.encoding

