archive = require '../lib/ls-archive'
path = require 'path'

describe "gzipped tar files", ->
  fixturesRoot = null

  beforeEach ->
    fixturesRoot = path.join(__dirname, 'fixtures')

  describe ".list()", ->
    it "returns files in the gzipped tar archive", ->
      gzipPaths = null
      callback = (paths) -> gzipPaths = paths
      archive.list(path.join(fixturesRoot, 'one-file.tar.gz'), callback)
      waitsFor -> gzipPaths?
      runs -> expect(gzipPaths).toEqual ['file.txt']

    it "returns folders in the gzipped tar archive", ->
      gzipPaths = null
      callback = (paths) -> gzipPaths = paths
      archive.list(path.join(fixturesRoot, 'one-folder.tar.gz'), callback)
      waitsFor -> gzipPaths?
      runs -> expect(gzipPaths).toEqual ['folder/']
