config = require '../lib/Config'
expect = require('./helpers/Common').expect
os = require 'os'
path = require 'path'


describe 'Config', ->
  beforeEach ->
    config.reset()

  describe '.init', ->
    it 'defaults to development APP_ENV', ->
      expect( config.APP_ENV ).to.equal 'development'
      opts =
        ENV:
          SOME_ENV: 1
      config.init opts
      # Test to make sure ENV is not globbering defaults
      expect( config.APP_ENV ).to.equal 'development'
      expect( config.development ).to.be.true

    it 'sets APP_ENV', ->
      opts =
        ENV:
          APP_ENV: 'production'
      config.init opts
      expect( config.APP_ENV ).to.equal 'production'
      expect( config.development ).to.be.false

  describe '.buildFile', ->
    it 'uses container.build', ->
      opts =
        container:
          build: '/some/path/to/Dockerfile'
          encoding: 'ascii'
      config.init opts
      expect( config.buildFile ).to.equal opts.container.build
      expect( config.buildFileEncoding ).to.equal opts.container.encoding

    it 'uses default container.build', ->
      config.init {}
      expect( config.buildFile ).to.equal config._defaults.container.build
      expect( config.buildFileEncoding ).to.equal config._defaults.container.encoding

  describe '.tmpDir', ->
    it 'is in OS tmp dir when not specified in paths', ->
      dir = config.tmpDir
      tmpdir = os.tmpdir()
      expect( tmpdir.length ).to.be.above 2
      expect( dir.substr 0, tmpdir.length ).to.equal tmpdir

    it 'uses paths.tmp when specified', ->
      config.init paths:
        base: './.airstack'
        tmp: 'tmp'
      dir = config.tmpDir
      tmpdir = os.tmpdir()
      expect( dir.substr 0, tmpdir.length ).to.not.equal tmpdir
      expect( dir ).to.equal path.join process.cwd(), './.airstack/tmp'
