archive = require '../lib/ls-archive'
path = require 'path'

describe "bzipped tar files", ->
  fixturesRoot = null

  beforeEach ->
    fixturesRoot = path.join(__dirname, 'fixtures')

  describe ".list()", ->
    describe "when the archive file exists", ->
      it "returns files in the bzipped tar archive", ->
        bzipPaths = null
        callback = (error, paths) -> bzipPaths = paths
        archive.list(path.join(fixturesRoot, 'one-file.tar.bz2'), callback)
        waitsFor -> bzipPaths?
        runs ->
          expect(bzipPaths.length).toBe 1
          expect(bzipPaths[0].path).toBe 'file.txt'
          expect(bzipPaths[0].isDirectory()).toBe false
          expect(bzipPaths[0].isFile()).toBe true
          expect(bzipPaths[0].isSymbolicLink()).toBe false

      it "returns files in the bzipped tar archive", ->
        bzipPaths = null
        callback = (error, paths) -> bzipPaths = paths
        archive.list(path.join(fixturesRoot, 'one-file.tbz'), callback)
        waitsFor -> bzipPaths?
        runs ->
          expect(bzipPaths.length).toBe 1
          expect(bzipPaths[0].path).toBe 'file.txt'
          expect(bzipPaths[0].isDirectory()).toBe false
          expect(bzipPaths[0].isFile()).toBe true
          expect(bzipPaths[0].isSymbolicLink()).toBe false
      
      it "returns files in the bzipped tar archive", ->
        bzipPaths = null
        callback = (error, paths) -> bzipPaths = paths
        archive.list(path.join(fixturesRoot, 'one-file.tbz2'), callback)
        waitsFor -> bzipPaths?
        runs ->
          expect(bzipPaths.length).toBe 1
          expect(bzipPaths[0].path).toBe 'file.txt'
          expect(bzipPaths[0].isDirectory()).toBe false
          expect(bzipPaths[0].isFile()).toBe true
          expect(bzipPaths[0].isSymbolicLink()).toBe false

      it "returns folders in the bzipped tar archive", ->
        bzipPaths = null
        callback = (error, paths) -> bzipPaths = paths
        archive.list(path.join(fixturesRoot, 'one-folder.tar.bz2'), callback)
        waitsFor -> bzipPaths?
        runs ->
          expect(bzipPaths.length).toBe 1
          expect(bzipPaths[0].path).toBe 'folder'
          expect(bzipPaths[0].isDirectory()).toBe true
          expect(bzipPaths[0].isFile()).toBe false
          expect(bzipPaths[0].isSymbolicLink()).toBe false

      it "returns folders in the bzipped tar archive", ->
        bzipPaths = null
        callback = (error, paths) -> bzipPaths = paths
        archive.list(path.join(fixturesRoot, 'one-folder.tbz'), callback)
        waitsFor -> bzipPaths?
        runs ->
          expect(bzipPaths.length).toBe 1
          expect(bzipPaths[0].path).toBe 'folder'
          expect(bzipPaths[0].isDirectory()).toBe true
          expect(bzipPaths[0].isFile()).toBe false
          expect(bzipPaths[0].isSymbolicLink()).toBe false
      
      it "returns folders in the bzipped tar archive", ->
        bzipPaths = null
        callback = (error, paths) -> bzipPaths = paths
        archive.list(path.join(fixturesRoot, 'one-folder.tbz2'), callback)
        waitsFor -> bzipPaths?
        runs ->
          expect(bzipPaths.length).toBe 1
          expect(bzipPaths[0].path).toBe 'folder'
          expect(bzipPaths[0].isDirectory()).toBe true
          expect(bzipPaths[0].isFile()).toBe false
          expect(bzipPaths[0].isSymbolicLink()).toBe false

    describe "when the archive path does not exist", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'not-a-file.tar.bz2')
        pathError = null
        callback = (error) -> pathError = error
        archive.list(archivePath, callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

    describe "when the archive path isn't a valid bzipped tar file", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.tar.bz2')
        pathError = null
        callback = (error) -> pathError = error
        archive.list(archivePath, callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

    describe "when the second to last extension isn't .tar", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.txt.bz2')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.list(archivePath, callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

  describe ".readFile()", ->
    describe "when the path exists in the archive", ->
      it "calls back with the contents of the given path", ->
        archivePath = path.join(fixturesRoot, 'one-file.tar.bz2')
        pathContents = null
        callback = (error, contents) -> pathContents = contents
        archive.readFile(archivePath, 'file.txt', callback)
        waitsFor -> pathContents?
        runs -> expect(pathContents.toString()).toBe 'hello\n'

      it "calls back with the contents of the given path", ->
        archivePath = path.join(fixturesRoot, 'one-file.tbz')
        pathContents = null
        callback = (error, contents) -> pathContents = contents
        archive.readFile(archivePath, 'file.txt', callback)
        waitsFor -> pathContents?
        runs -> expect(pathContents.toString()).toBe 'hello\n'
      
      it "calls back with the contents of the given path", ->
        archivePath = path.join(fixturesRoot, 'one-file.tbz2')
        pathContents = null
        callback = (error, contents) -> pathContents = contents
        archive.readFile(archivePath, 'file.txt', callback)
        waitsFor -> pathContents?
        runs -> expect(pathContents.toString()).toBe 'hello\n'

    describe "when the path does not exist in the archive", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'one-file.tar.bz2')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'not-a-file.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

    describe "when the archive path does not exist", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'not-a-file.tar.bz2')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'not-a-file.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

    describe "when the archive path isn't a valid bzipped tar file", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.tar.bz2')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'invalid.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

    describe "when the second to last extension isn't .tar", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.txt.bz2')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'invalid.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

  describe ".readBzip()", ->
    it "calls back with the string contents of the archive", ->
      archivePath = path.join(fixturesRoot, 'file.txt.bz2')
      archiveContents = null
      callback = (error, contents) -> archiveContents = contents
      archive.readBzip(archivePath, callback)
      waitsFor -> archiveContents?
      runs -> expect(archiveContents.toString()).toBe 'hello\n'

    describe "when the archive path isn't a valid bzipped tar file", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.tar.bz2')
        readError = null
        callback = (error, contents) -> readError = error
        archive.readBzip(archivePath, callback)
        waitsFor -> readError?
        runs -> expect(readError.message.length).toBeGreaterThan 0

    describe "when the archive path does not exist", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'not-a-file.tar.bz2')
        readError = null
        callback = (error, contents) -> readError = error
        archive.readBzip(archivePath, callback)
        waitsFor -> readError?
        runs -> expect(readError.message.length).toBeGreaterThan 0
