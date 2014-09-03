utils = require '../../../../lib/utils'
expect = require('../../../helpers/Common').expect


describe 'utils', ->

  describe '#defaults', ->
    it 'does deep merge', ->
      defaults =
        a:
          aa: 1
          ab: 2
        b: true
        d: 111
      opts =
        a:
          aa: -1
          ac: -2
        c: false
        d: 222
      utils.defaults opts, defaults
      expect( opts.a.aa ).to.equal -1
      expect( opts.a.ab ).to.equal 2
      expect( opts.a.ac ).to.equal -2
      expect( opts.b ).to.be.true
      expect( opts.c ).to.be.false
      expect( opts.d ).to.equal 222



