archive = require '../lib/ls-archive'
path = require 'path'

describe "gzipped tar file listing", ->
  fixturesRoot = path.join(__dirname, 'fixtures')

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
