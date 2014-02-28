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
        callback = (error, paths) -> gzipPaths = paths
        archive.list(path.join(fixturesRoot, 'one-file.tar.gz'), callback)
        waitsFor -> gzipPaths?
        runs ->
          expect(gzipPaths.length).toBe 1
          expect(gzipPaths[0].path).toBe 'file.txt'
          expect(gzipPaths[0].isDirectory()).toBe false
          expect(gzipPaths[0].isFile()).toBe true
          expect(gzipPaths[0].isSymbolicLink()).toBe false

      it "returns files in the gzipped tar archive", ->
        gzipPaths = null
        callback = (error, paths) -> gzipPaths = paths
        archive.list(path.join(fixturesRoot, 'one-file.tgz'), callback)
        waitsFor -> gzipPaths?
        runs ->
          expect(gzipPaths.length).toBe 1
          expect(gzipPaths[0].path).toBe 'file.txt'
          expect(gzipPaths[0].isDirectory()).toBe false
          expect(gzipPaths[0].isFile()).toBe true
          expect(gzipPaths[0].isSymbolicLink()).toBe false

      it "returns folders in the gzipped tar archive", ->
        gzipPaths = null
        callback = (error, paths) -> gzipPaths = paths
        archive.list(path.join(fixturesRoot, 'one-folder.tar.gz'), callback)
        waitsFor -> gzipPaths?
        runs ->
          expect(gzipPaths.length).toBe 1
          expect(gzipPaths[0].path).toBe 'folder'
          expect(gzipPaths[0].isDirectory()).toBe true
          expect(gzipPaths[0].isFile()).toBe false
          expect(gzipPaths[0].isSymbolicLink()).toBe false

      it "returns folders in the gzipped tar archive", ->
        gzipPaths = null
        callback = (error, paths) -> gzipPaths = paths
        archive.list(path.join(fixturesRoot, 'one-folder.tgz'), callback)
        waitsFor -> gzipPaths?
        runs ->
          expect(gzipPaths.length).toBe 1
          expect(gzipPaths[0].path).toBe 'folder'
          expect(gzipPaths[0].isDirectory()).toBe true
          expect(gzipPaths[0].isFile()).toBe false
          expect(gzipPaths[0].isSymbolicLink()).toBe false

    describe "when the archive path does not exist", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'not-a-file.tar.gz')
        pathError = null
        callback = (error) -> pathError = error
        archive.list(archivePath, callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

    describe "when the archive path isn't a valid gzipped tar file", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.tar.gz')
        pathError = null
        callback = (error) -> pathError = error
        archive.list(archivePath, callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

    describe "when the second to last extension isn't .tar", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.txt.gz')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.list(archivePath, callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

  describe ".readFile()", ->
    describe "when the path exists in the archive", ->
      it "calls back with the contents of the given path", ->
        archivePath = path.join(fixturesRoot, 'one-file.tar.gz')
        pathContents = null
        callback = (error, contents) -> pathContents = contents
        archive.readFile(archivePath, 'file.txt', callback)
        waitsFor -> pathContents?
        runs -> expect(pathContents.toString()).toBe 'hello\n'

      it "calls back with the contents of the given path", ->
        archivePath = path.join(fixturesRoot, 'one-file.tgz')
        pathContents = null
        callback = (error, contents) -> pathContents = contents
        archive.readFile(archivePath, 'file.txt', callback)
        waitsFor -> pathContents?
        runs -> expect(pathContents.toString()).toBe 'hello\n'

    describe "when the path does not exist in the archive", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'one-file.tar.gz')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'not-a-file.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

    describe "when the archive path does not exist", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'not-a-file.tar.gz')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'not-a-file.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

    describe "when the archive path isn't a valid gzipped tar file", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.tar.gz')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'invalid.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

    describe "when the second to last extension isn't .tar", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.txt.gz')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'invalid.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

  describe ".readGzip()", ->
    it "calls back with the string contents of the archive", ->
      archivePath = path.join(fixturesRoot, 'file.txt.gz')
      archiveContents = null
      callback = (error, contents) -> archiveContents = contents
      archive.readGzip(archivePath, callback)
      waitsFor -> archiveContents?
      runs -> expect(archiveContents.toString()).toBe 'hello\n'

    describe "when the archive path isn't a valid gzipped tar file", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.tar.gz')
        readError = null
        callback = (error, contents) -> readError = error
        archive.readGzip(archivePath, callback)
        waitsFor -> readError?
        runs -> expect(readError.message.length).toBeGreaterThan 0

    describe "when the archive path does not exist", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'not-a-file.tar.gz')
        readError = null
        callback = (error, contents) -> readError = error
        archive.readGzip(archivePath, callback)
        waitsFor -> readError?
        runs -> expect(readError.message.length).toBeGreaterThan 0
