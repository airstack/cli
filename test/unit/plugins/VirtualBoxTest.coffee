VirtualBox = require '../../../plugins/VirtualBox'
expect = require('../../helpers/Common').expect


describe 'VirtualBox', ->
  vb = new VirtualBox

  describe '.status', ->
    # TODO: speed up tests with mocks
    xit 'resolves promise', (done) ->
      vb.status()
      .then (status, code) ->
        done()

  describe '.up', (done) ->

