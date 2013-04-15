archive = require '../lib/ls-archive'
path = require 'path'

describe "gzipped tar files", ->
  fixturesRoot = null

  beforeEach ->
    fixturesRoot = path.join(__dirname, 'fixtures')

  describe ".list()", ->
    describe "when the archive file exists", ->
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

    describe "when the archive path does not exist", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'not-a-file.tar.gz')
        pathError = null
        callback = (error) -> pathError = error
        archive.list(archivePath, callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message).not.toBeNull()

    describe "when the archive path isn't a valid gzipped tar file", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.tar.gz')
        pathError = null
        callback = (error) -> pathError = error
        archive.list(archivePath, callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message).not.toBeNull()

  describe ".readFile()", ->
    describe "when the path exists in the archive", ->
      it "calls back with the contents of the given path", ->
        archivePath = path.join(fixturesRoot, 'one-file.tar.gz')
        pathContents = null
        callback = (error, contents) -> pathContents = contents
        archive.readFile(archivePath, 'file.txt', callback)
        waitsFor -> pathContents?
        runs -> expect(pathContents).toBe 'hello\n'

    describe "when the path does not exist in the archive", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'one-file.tar.gz')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'not-a-file.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message).not.toBeNull()

    describe "when the archive path does not exist", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'not-a-file.tar.gz')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'not-a-file.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message).not.toBeNull()

    describe "when the archive path isn't a valid gzipped tar file", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.tar.gz')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'invalid.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message).not.toBeNull()

    describe "when the second to last extension isn't .tar", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.txt.gz')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'invalid.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message).not.toBeNull()
