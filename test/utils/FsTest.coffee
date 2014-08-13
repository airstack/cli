utils = require '../../lib/utils'
expect = require('../helpers/Common').expect
path = require 'path'
os = require 'os'
fs = require 'fs'


describe 'utils.fs', ->
  describe '#mkdir', ->
    it 'creates parent directories', (done) ->
      mode = 0o754
      subdirs = for i in [1..5]
        utils.string.random 5
      dir = path.join.apply null, subdirs
      dir = path.join path.dirname(utils.fs.randomTmpFile 'a'), dir
      utils.fs.mkdir dir, mode
      .then ->
        expect( fs.existsSync dir ).to.equal true
        expect( fs.statSync(dir).mode & 0o777 ).to.equal mode
        done()

  describe '#randomTmpFile', ->
    it 'has path in OS tmp dir', ->
      file = utils.fs.randomTmpFile()
      tmpdir = os.tmpdir()
      expect( tmpdir.length ).to.be.above 2
      expect( file.substr 0, tmpdir.length ).to.equal tmpdir

    it 'uses filename when provided', ->
      filename = 'SOME_SPECIFIC_FILENAME'
      file = utils.fs.randomTmpFile filename
      expect( path.basename file ).to.equal filename

  describe '#randomTmpDir', ->
    it 'is in OS tmp dir', ->
      dir = utils.fs.randomTmpDir()
      tmpdir = os.tmpdir()
      expect( tmpdir.length ).to.be.above 2
      expect( dir.substr 0, tmpdir.length ).to.equal tmpdir




