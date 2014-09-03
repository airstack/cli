Bundler = require '../../../lib/Bundler'
utils = require '../../../lib/utils'
expect = require('../../helpers/Common').expect

describe 'Bundler', ->

  describe '#append', (done) ->

    xit 'appends file', ->
      # todo: test API instead of testing Tar
      # mock bundler._tape and verify Promises work
      tarFile = utils.fs.randomTmpFile() + '.tar'
      bundler = new Bundler tarFile
      bundler.append tarFile, contents, null, ->
        bundler.close ->
          untar = Tar.Untar

  # todo: convert to promises

  # todo: test close callback

