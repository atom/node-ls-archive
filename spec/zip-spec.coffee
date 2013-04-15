archive = require '../lib/ls-archive'
path = require 'path'

describe "zip file listing", ->
  fixturesRoot = null

  beforeEach ->
    fixturesRoot = path.join(__dirname, 'fixtures')

  describe ".list()", ->
    it "returns files in the zip archive", ->
      zipPaths = null
      callback = (paths) -> zipPaths = paths
      archive.list(path.join(fixturesRoot, 'one-file.zip'), callback)
      waitsFor -> zipPaths?
      runs -> expect(zipPaths).toEqual ['file.txt']

    it "returns folders in the zip archive", ->
      zipPaths = null
      callback = (paths) -> zipPaths = paths
      archive.list(path.join(fixturesRoot, 'one-folder.zip'), callback)
      waitsFor -> zipPaths?
      runs -> expect(zipPaths).toEqual ['folder/']
