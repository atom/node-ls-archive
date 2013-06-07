fs = require 'fs'
path = require 'path'
util = require 'util'
_ = require 'underscore'

class ArchiveEntry
  constructor: (@path, @type) ->
    @children = [] if @isDirectory()

  add: (entry, segments) ->
    return false unless @isDirectory()

    segments ?= entry.getPath().split('/')
    return false unless segments.shift() is @getName()

    if segments.length is 1
      @children.push(entry)
      true
    else
      for child in @children
        return true if child.add(entry, segments)
      false

  getPath: -> @path
  getName: -> path.basename(@path)
  isFile: -> @type is 0
  isDirectory: -> @type is 5
  isSymbolicLink: -> @type is 2
  toString: -> @getPath()

convertToTree = (entries) ->
  rootEntries = []
  for entry in entries
    segments = entry.getPath().split('/')
    if segments.length is 1
      rootEntries.push(entry)
    else
      for rootEntry in rootEntries
        break if rootEntry.add(entry)
  rootEntries

wrapCallback = (callback) ->
  called = false
  (error, data) ->
    unless called
      error = new Error(error) if error? and not util.isError(error)
      called = true
      callback(error, data)

listZip = (archivePath, options, callback) ->
  unzip = require 'unzip'
  entries = []
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', callback
  zipStream = fileStream.pipe(unzip.Parse())
  zipStream.on 'close', ->
    entries = convertToTree(entries) if options.tree
    callback(null, entries)
  zipStream.on 'error', callback
  zipStream.on 'entry', (entry) ->
    if entry.path[-1..] is '/'
      entryPath = entry.path[0...-1]
    else
      entryPath = entry.path
    switch entry.type
      when 'Directory' then entryType = 5
      when 'File' then entryType = 0
      else entryType = -1
    entries.push(new ArchiveEntry(entryPath, entryType))
    entry.autodrain()

listGzip = (archivePath, options, callback) ->
  zlib = require 'zlib'
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', callback
  gzipStream = fileStream.pipe(zlib.createGunzip())
  gzipStream.on 'error', callback
  listTarStream(gzipStream, options, callback)

listTar = (archivePath, options, callback) ->
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', callback
  listTarStream(fileStream, options, callback)

listTarStream = (inputStream, options, callback) ->
  entries = []
  tarStream = inputStream.pipe(require('tar').Parse())
  tarStream.on 'error', callback
  tarStream.on 'entry', (entry) ->
    if entry.props.path[-1..] is '/'
      entryPath = entry.props.path[0...-1]
    else
      entryPath = entry.props.path
    entryType = parseInt(entry.props.type)
    entries.push(new ArchiveEntry(entryPath, entryType))
  tarStream.on 'end', ->
    entries = convertToTree(entries) if options.tree
    callback(null, entries)

readFileFromZip = (archivePath, filePath, callback) ->
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', callback
  zipStream = fileStream.pipe(require('unzip').Parse())
  zipStream.on 'close', ->
    callback("#{filePath} does not exist in the archive: #{archivePath}")
  zipStream.on 'error', callback
  zipStream.on 'entry', (entry) ->
    if filePath is entry.path
      if entry.type is 'File'
        readEntry(entry, callback)
      else
        callback("#{filePath} is a folder in the archive: #{archivePath}")
        entry.autodrain()
    else
      entry.autodrain()

readFileFromGzip = (archivePath, filePath, callback) ->
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', callback
  gzipStream = fileStream.pipe(require('zlib').createGunzip())
  gzipStream.on 'error', callback
  gzipStream.on 'end', ->
    callback("#{filePath} does not exist in the archive: #{archivePath}")
  readFileFromTarStream(gzipStream, archivePath, filePath, callback)

readFileFromTar = (archivePath, filePath, callback) ->
  fileStream = fs.createReadStream(archivePath, callback)
  fileStream.on 'error', callback
  fileStream.on 'end', ->
    callback("#{filePath} does not exist in the archive: #{archivePath}")
  readFileFromTarStream(fileStream, archivePath, filePath, callback)

readFileFromTarStream = (inputStream, archivePath, filePath, callback) ->
  tar = require 'tar'
  tarStream = inputStream.pipe(tar.Parse())

  tarStream.on 'error', callback
  tarStream.on 'entry', (entry) ->
    return unless filePath is entry.props.path

    if entry.props.type is '0'
      readEntry(entry, callback)
    else
      callback("#{filePath} is not a normal file in the archive: #{archivePath}")

readEntry = (entry, callback) ->
  contents = []
  entry.on 'data', (data) -> contents.push(data)
  entry.on 'end', -> callback(null, Buffer.concat(contents).toString())

isTarPath = (archivePath) ->
  path.extname(archivePath) is '.tar'

isZipPath = (archivePath) ->
  extension = path.extname(archivePath)
  extension is '.zip' or extension is '.jar'

isGzipPath = (archivePath) ->
  path.extname(archivePath) is '.tgz' or
    path.extname(path.basename(archivePath, '.gz')) is '.tar'

module.exports =
  isPathSupported: (archivePath) ->
    return false unless archivePath
    isTarPath(archivePath) or isZipPath(archivePath) or isGzipPath(archivePath)

  list: (archivePath, options={}, callback) ->
    if _.isFunction(options)
      callback = options
      options = {}

    if isTarPath(archivePath)
      listTar(archivePath, options, wrapCallback(callback))
    else if isGzipPath(archivePath)
      listGzip(archivePath, options, wrapCallback(callback))
    else if isZipPath(archivePath)
      listZip(archivePath, options, wrapCallback(callback))
    else
      callback(new Error("'#{path.extname(archivePath)}' files are not supported"))
    undefined

  readFile: (archivePath, filePath, callback) ->
    if isTarPath(archivePath)
      readFileFromTar(archivePath, filePath, wrapCallback(callback))
    else if isGzipPath(archivePath)
      readFileFromGzip(archivePath, filePath, wrapCallback(callback))
    else if isZipPath(archivePath)
      readFileFromZip(archivePath, filePath, wrapCallback(callback))
    else
      callback(new Error("'#{path.extname(archivePath)}' files are not supported"))
    undefined

  readGzip: (gzipArchivePath, callback) ->
    callback = wrapCallback(callback)

    zlib = require 'zlib'
    fileStream = fs.createReadStream(gzipArchivePath)
    fileStream.on 'error', callback
    gzipStream = fileStream.pipe(zlib.createGunzip())
    gzipStream.on 'error', callback

    chunks = []
    gzipStream.on 'data', (chunk) ->
      chunks.push(chunk)
    gzipStream.on 'end', ->
      callback(null, Buffer.concat(chunks).toString())
