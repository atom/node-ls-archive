archive = require '../lib/ls-archive'
path = require 'path'

describe "tar files", ->
  fixturesRoot = null

  beforeEach ->
    fixturesRoot = path.join(__dirname, 'fixtures')

  describe ".list()", ->
    it "returns files in the tar archive", ->
      tarPaths = null
      callback = (paths) -> tarPaths = paths
      archive.list(path.join(fixturesRoot, 'one-file.tar'), callback)
      waitsFor -> tarPaths?
      runs -> expect(tarPaths).toEqual ['file.txt']

    it "returns folders in the tar archive", ->
      tarPaths = null
      callback = (paths) -> tarPaths = paths
      archive.list(path.join(fixturesRoot, 'one-folder.tar'), callback)
      waitsFor -> tarPaths?
      runs -> expect(tarPaths).toEqual ['folder/']
