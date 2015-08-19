archive = require '../lib/ls-archive'
path = require 'path'

describe "Common behavior", ->
  describe ".list()", ->
    it "calls back with an error for unsupported extensions", ->
      pathError = null
      callback = (error) -> pathError = error
      archive.list(path.join('tmp', 'file.txt'), callback)
      waitsFor -> pathError?
      runs -> expect(pathError.message).not.toBeNull()

    it "returns undefined", ->
      expect(archive.list(path.join('tmp', 'file.zip'), ->)).toBeUndefined()

  describe ".readFile()", ->
    it "calls back with an error for unsupported extensions", ->
      pathError = null
      callback = (error) -> pathError = error
      archive.readFile(path.join('tmp', 'file.txt'), 'file.txt', callback)
      waitsFor -> pathError?
      runs -> expect(pathError.message).not.toBeNull()

    it "returns undefined", ->
      expect(archive.readFile(path.join('tmp', 'file.txt'), 'file.txt', ->)).toBeUndefined()

  describe ".isPathSupported()", ->
    it "returns true for supported path extensions", ->
      expect(archive.isPathSupported("#{path.sep}a.epub")).toBe true
      expect(archive.isPathSupported("#{path.sep}a.zip")).toBe true
      expect(archive.isPathSupported("#{path.sep}a.jar")).toBe true
      expect(archive.isPathSupported("#{path.sep}a.war")).toBe true
      expect(archive.isPathSupported("#{path.sep}a.tar")).toBe true
      expect(archive.isPathSupported("#{path.sep}a.tgz")).toBe true
      expect(archive.isPathSupported("#{path.sep}a.tar.gz")).toBe true
      expect(archive.isPathSupported("#{path.sep}a.whl")).toBe true
      expect(archive.isPathSupported("#{path.sep}a.egg")).toBe true
      expect(archive.isPathSupported("#{path.sep}a.xpi")).toBe true
      expect(archive.isPathSupported("#{path.sep}a.nupkg")).toBe true
      expect(archive.isPathSupported("#{path.sep}a.bar.gz")).toBe false
      expect(archive.isPathSupported("#{path.sep}a.txt")).toBe false
      expect(archive.isPathSupported("#{path.sep}")).toBe false
      expect(archive.isPathSupported('')).toBe false
      expect(archive.isPathSupported(null)).toBe false
      expect(archive.isPathSupported()).toBe false
