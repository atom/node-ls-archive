archive = require '../lib/ls-archive'

describe "Common behavior", ->
  describe ".list()", ->
    it "calls back with an error for unsupported extensions", ->
      pathError = null
      callback = (error) -> pathError = error
      archive.list('/tmp/file.txt', callback)
      waitsFor -> pathError?
      runs -> expect(pathError.message).not.toBeNull()

  describe ".readFile()", ->
    it "calls back with an error for unsupported extensions", ->
      pathError = null
      callback = (error) -> pathError = error
      archive.readFile('/tmp/file.txt', 'file.txt', callback)
      waitsFor -> pathError?
      runs -> expect(pathError.message).not.toBeNull()
