VirtualBox = require '../../lib/plugins/VirtualBox'
expect = require('../helpers/Common').expect

# TODO: speed up tests with mocks

describe 'VirtualBox', ->
  vb = new VirtualBox

  describe '.status', ->
    it 'resolves promise', (done) ->
      vb.status()
      .then (status, code) ->
        done()

  describe '.up', (done) ->

