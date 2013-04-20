fs = require 'fs'
path = require 'path'
util = require 'util'

class ArchiveEntry
  constructor: (@path, @type) ->

  getPath: -> @path
  isFile: -> @type is 0
  isDirectory: -> @type is 5
  isSymbolicLink: -> @type is 2

wrapCallback = (callback) ->
  called = false
  (error, data) ->
    unless called
      error = new Error(error) if error? and not util.isError(error)
      called = true
      callback(error, data)

listZip = (archivePath, callback) ->
  unzip = require 'unzip'
  paths = []
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', callback
  zipStream = fileStream.pipe(unzip.Parse())
  zipStream.on 'close', -> callback(null, paths)
  zipStream.on 'error', callback
  zipStream.on 'entry', (entry) ->
    if entry.path[-1..] is '/'
      entryPath = entry.path[0...-1]
    else
      entryPath = entry.path
    if entry.type is 'Directory'
      entryType = 5
    else if entry.type is 'File'
      entryType = 0
    else
      entryType = -1
    paths.push(new ArchiveEntry(entryPath, entryType))
    entry.autodrain()

listGzip = (archivePath, callback) ->
  if path.extname(path.basename(archivePath, '.gz')) isnt '.tar'
    callback("'#{path.extname(archivePath)}' files are not supported")
    return

  zlib = require 'zlib'
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', callback
  gzipStream = fileStream.pipe(zlib.createGunzip())
  gzipStream.on 'error', callback
  listTarStream(gzipStream, callback)

listTar = (archivePath, callback) ->
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', callback
  listTarStream(fileStream, callback)

listTarStream = (inputStream, callback) ->
  paths = []
  tarStream = inputStream.pipe(require('tar').Parse())
  tarStream.on 'error', callback
  tarStream.on 'entry', (entry) ->
    if entry.props.path[-1..] is '/'
      entryPath = entry.props.path[0...-1]
    else
      entryPath = entry.props.path
    entryType = parseInt(entry.props.type)
    paths.push(new ArchiveEntry(entryPath, entryType))
  tarStream.on 'end', -> callback(null, paths)

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
  if path.extname(path.basename(archivePath, '.gz')) isnt '.tar'
    callback("'#{path.extname(archivePath)}' files are not supported")
    return

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

module.exports =
  list: (archivePath, callback) ->
    switch path.extname(archivePath)
      when '.tar' then listTar(archivePath, wrapCallback(callback))
      when '.gz' then listGzip(archivePath, wrapCallback(callback))
      when '.zip' then listZip(archivePath, wrapCallback(callback))
      else callback(new Error("'#{path.extname(archivePath)}' files are not supported"))
    undefined

  readFile: (archivePath, filePath, callback) ->
    switch path.extname(archivePath)
      when '.tar' then readFileFromTar(archivePath, filePath, wrapCallback(callback))
      when '.gz' then readFileFromGzip(archivePath, filePath, wrapCallback(callback))
      when '.zip' then readFileFromZip(archivePath, filePath, wrapCallback(callback))
      else callback(new Error("'#{path.extname(archivePath)}' files are not supported"))
    undefined
