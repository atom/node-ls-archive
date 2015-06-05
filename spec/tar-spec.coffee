archive = require '../lib/ls-archive'
path = require 'path'

describe "tar files", ->
  fixturesRoot = null

  beforeEach ->
    fixturesRoot = path.join(__dirname, 'fixtures')

  describe ".list()", ->
    describe "when the archive file exists", ->
      it "returns files in the tar archive", ->
        tarPaths = null
        callback = (error, paths) -> tarPaths = paths
        archive.list(path.join(fixturesRoot, 'one-file.tar'), callback)
        waitsFor -> tarPaths?
        runs ->
          expect(tarPaths.length).toBe 1
          expect(tarPaths[0].path).toBe 'file.txt'
          expect(tarPaths[0].isDirectory()).toBe false
          expect(tarPaths[0].isFile()).toBe true
          expect(tarPaths[0].isSymbolicLink()).toBe false

      it "returns folders in the tar archive", ->
        tarPaths = null
        callback = (error, paths) -> tarPaths = paths
        archive.list(path.join(fixturesRoot, 'one-folder.tar'), callback)
        waitsFor -> tarPaths?
        runs ->
          expect(tarPaths.length).toBe 1
          expect(tarPaths[0].path).toBe 'folder'
          expect(tarPaths[0].isDirectory()).toBe true
          expect(tarPaths[0].isFile()).toBe false
          expect(tarPaths[0].isSymbolicLink()).toBe false

      describe "when the tree option is set to true", ->
        describe "when the archive has no directories entries", ->
          it "returns archive entries nested under their parent directory", ->
            tree = null
            archive.list path.join(__dirname, 'fixtures', 'no-dir-entries.tgz'), tree: true, (error, files) ->
              tree = files
            waitsFor -> tree?
            runs ->
              expect(tree.length).toBe 1
              expect(tree[0].getName()).toBe 'package'
              expect(tree[0].getPath()).toBe 'package'
              expect(tree[0].children.length).toBe 5
              expect(tree[0].children[0].getName()).toBe 'package.json'
              expect(tree[0].children[0].getPath()).toBe path.join('package', 'package.json')
              expect(tree[0].children[1].getName()).toBe 'README.md'
              expect(tree[0].children[1].getPath()).toBe path.join('package', 'README.md')
              expect(tree[0].children[2].getName()).toBe 'LICENSE.md'
              expect(tree[0].children[2].getPath()).toBe path.join('package', 'LICENSE.md')
              expect(tree[0].children[3].getName()).toBe 'bin'
              expect(tree[0].children[3].getPath()).toBe path.join('package', 'bin')
              expect(tree[0].children[4].children[0].getName()).toBe 'lister.js'
              expect(tree[0].children[4].children[0].getPath()).toBe path.join('package', 'lib', 'lister.js')
              expect(tree[0].children[4].children[1].getName()).toBe 'ls-archive-cli.js'
              expect(tree[0].children[4].children[1].getPath()).toBe path.join('package', 'lib', 'ls-archive-cli.js')
              expect(tree[0].children[4].children[2].getName()).toBe 'ls-archive.js'
              expect(tree[0].children[4].children[2].getPath()).toBe path.join('package', 'lib', 'ls-archive.js')
              expect(tree[0].children[4].children[3].getName()).toBe 'reader.js'
              expect(tree[0].children[4].children[3].getPath()).toBe path.join('package', 'lib', 'reader.js')

        describe "when the archive has multiple directories at the root", ->
          it "returns archive entries nested under their parent directory", ->
            tree = null
            archive.list path.join(__dirname, 'fixtures', 'nested.tar'), tree: true, (error, files) ->
              tree = files
            waitsFor -> tree?
            runs ->
              expect(tree.length).toBe 2

              expect(tree[0].getPath()).toBe 'd1'
              expect(tree[0].children[0].getName()).toBe 'd2'
              expect(tree[0].children[0].children[0].getName()).toBe 'd3'
              expect(tree[0].children[0].children[1].getName()).toBe 'f1.txt'
              expect(tree[0].children[1].getName()).toBe 'd4'
              expect(tree[0].children[2].getName()).toBe 'f2.txt'

              expect(tree[1].getPath()).toBe 'da'
              expect(tree[1].children[0].getName()).toBe 'db'
              expect(tree[1].children[1].getName()).toBe 'fa.txt'

    describe "when the archive path does not exist", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'not-a-file.tar')
        pathError = null
        callback = (error) -> pathError = error
        archive.list(archivePath, callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

    describe "when the archive path isn't a valid tar file", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.tar')
        pathError = null
        callback = (error) -> pathError = error
        archive.list(archivePath, callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

  describe ".readFile()", ->
    describe "when the path exists in the archive", ->
      it "calls back with the contents of the given path", ->
        archivePath = path.join(fixturesRoot, 'one-file.tar')
        pathContents = null
        callback = (error, contents) -> pathContents = contents
        archive.readFile(archivePath, 'file.txt', callback)
        waitsFor -> pathContents?
        runs -> expect(pathContents.toString()).toBe 'hello\n'

    describe "when the path does not exist in the archive", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'one-file.tar')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'not-a-file.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

    describe "when the archive path does not exist", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'not-a-file.tar')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'not-a-file.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

    describe "when the archive path isn't a valid tar file", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'invalid.tar')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, 'invalid.txt', callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0

    describe "when the path is a folder", ->
      it "calls back with an error", ->
        archivePath = path.join(fixturesRoot, 'one-folder.tar')
        pathError = null
        callback = (error, contents) -> pathError = error
        archive.readFile(archivePath, "folder#{path.sep}", callback)
        waitsFor -> pathError?
        runs -> expect(pathError.message.length).toBeGreaterThan 0
