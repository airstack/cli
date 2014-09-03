utils = require '../../../../lib/utils'
expect = require('../../../helpers/Common').expect


describe 'utils.string', ->

  describe '#randomString', ->
    it 'returns the correct string length', ->
      str = utils.string.random 7
      expect( str.length ).to.equal 7

    it 'uses specified chars', ->
      chars = '@+-'
      len = 3
      str = utils.string.random len, chars
      expect( str.match(///^[#{chars}]{#{len}}$///)[0] ).to.equal str

