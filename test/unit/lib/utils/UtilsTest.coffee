_ = require 'lodash'
_.defaults = require('../../../../lib/utils/object').deepDefaults
expect = require('../../../helpers/Common').expect


describe 'utils', ->

  describe '#defaults', ->
    it 'does deep merge', ->
      defaults =
        a:
          aa: 1
          ab: 2
          ac:
            aca: 'deep'
        b: true
        d: 111
      opts =
        a:
          aa: -1
          ac:
            acb: -2
        c: false
        d: 222
      _.defaults opts, defaults
      expect( opts.a.aa ).to.equal -1
      expect( opts.a.ab ).to.equal 2
      expect( opts.a.ac.acb ).to.equal -2
      expect( opts.b ).to.be.true
      expect( opts.c ).to.be.false
      expect( opts.d ).to.equal 222
      expect( opts.a.ac.aca ).to.equal 'deep'

