Parser = require '../../../lib/Parser'
expect = require('../../helpers/Common').expect
path = require 'path'

yamlFile = path.resolve __dirname, '../../../.airstack.yml'
badFile = path.resolve __dirname, './.SOME_FILE_THAT_DOES_NOT_EXIST.yml'


describe 'Parser', ->

  describe '#_loadFile', ->
    it 'loads file using promises', (done) ->
      Parser._loadFile(yamlFile).then (contents) ->
        expect(contents).to.exist
        done()
      .catch (err) ->
        done err

    it 'throws error if file does not exist', (done) ->
      Parser._loadFile(badFile).then (contents) ->
        done new Error 'File should not exist'
      .catch (err) ->
        done()

  describe '#loadYaml', ->
    it 'loads yaml file and resolves promise', (done) ->
      Parser.loadYaml(yamlFile).then (contents) ->
        expect(contents.name).to.exist
        done()
      .catch (err) ->
        done err
