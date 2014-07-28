Utils = require '../lib/Utils'
expect = require('./helpers/Common').expect
path = require 'path'
os = require 'os'
fs = require 'fs'


describe 'Utils', ->

  describe '#mkdirSync', ->
    it 'creates parent directories', ->
      mode = 0o754
      subdirs = for i in [1..5]
        Utils.randomString 5
      dir = path.join.apply null, subdirs
      dir = path.join path.dirname(Utils.randomTmpFile 'a'), dir
      console.log dir
      Utils.mkdirSync dir, mode
      expect( fs.existsSync dir ).to.equal true
      expect( fs.statSync(dir).mode & 0o777 ).to.equal mode

  describe '#randomString', ->
    it 'returns the correct string length', ->
      str = Utils.randomString 7
      expect( str.length ).to.equal 7

    it 'uses specified chars', ->
      chars = '@+-'
      len = 3
      str = Utils.randomString len, chars
      expect( str.match(///^[#{chars}]{#{len}}$///)[0] ).to.equal str

  describe '#randomTmpFile', ->
    it 'has path in OS tmp dir', ->
      file = Utils.randomTmpFile()
      tmpdir = os.tmpdir()
      expect( tmpdir.length ).to.be.above 2
      expect( file.substr 0, tmpdir.length ).to.equal tmpdir

    it 'uses filename when provided', ->
      filename = 'SOME_SPECIFIC_FILENAME'
      file = Utils.randomTmpFile filename
      expect( path.basename file ).to.equal filename

