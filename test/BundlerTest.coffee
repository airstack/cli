Bundler = require '../lib/Bundler'
expect = require('./helpers/Common').expect
utils = require '../lib/utils'

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

