archive = require '../lib/ls-archive'

describe "Common behavior", ->
  describe ".list()", ->
    it "calls back with an error for unsupported extensions", ->
      pathError = null
      callback = (error) -> pathError = error
      archive.list('/tmp/file.txt', callback)
      waitsFor -> pathError?
      runs -> expect(pathError.message).not.toBeNull()

    it "returns undefined", ->
      expect(archive.list('/tmp/file.zip', ->)).toBeUndefined()

  describe ".readFile()", ->
    it "calls back with an error for unsupported extensions", ->
      pathError = null
      callback = (error) -> pathError = error
      archive.readFile('/tmp/file.txt', 'file.txt', callback)
      waitsFor -> pathError?
      runs -> expect(pathError.message).not.toBeNull()

    it "returns undefined", ->
      expect(archive.readFile('/tmp/file.zip', 'file.txt', ->)).toBeUndefined()

  describe ".isPathSupported()", ->
    it "returns true for supported path extensions", ->
      expect(archive.isPathSupported('/a.epub')).toBe true
      expect(archive.isPathSupported('/a.zip')).toBe true
      expect(archive.isPathSupported('/a.jar')).toBe true
      expect(archive.isPathSupported('/a.war')).toBe true
      expect(archive.isPathSupported('/a.tar')).toBe true
      expect(archive.isPathSupported('/a.tgz')).toBe true
      expect(archive.isPathSupported('/a.tar.gz')).toBe true
      expect(archive.isPathSupported('/a.whl')).toBe true
      expect(archive.isPathSupported('/a.egg')).toBe true
      expect(archive.isPathSupported('/a.xpi')).toBe true
      expect(archive.isPathSupported('/a.bar.gz')).toBe false
      expect(archive.isPathSupported('/a.txt')).toBe false
      expect(archive.isPathSupported('/')).toBe false
      expect(archive.isPathSupported('')).toBe false
      expect(archive.isPathSupported(null)).toBe false
      expect(archive.isPathSupported()).toBe false
