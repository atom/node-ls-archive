fs = require 'fs'
path = require 'path'
util = require 'util'

wrapCallback = (callback) ->
  called = false
  (error, data) ->
    unless called
      error = new Error(error) unless util.isError(error)
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
    paths.push(entry.path)
    entry.autodrain()

listGzip = (archivePath, callback) ->
  if path.extname(path.basename(archivePath, '.gz')) isnt '.tar'
    callback([])
    return

  zlib = require 'zlib'
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', callback
  gzipStream = fileStream.pipe(zlib.createGunzip())
  gzipStream.on 'error', callback
  readTarStream(gzipStream, callback)

listTar = (archivePath, callback) ->
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', callback
  readTarStream(fileStream, callback)

readTarStream = (inputStream, callback) ->
  paths = []
  tarStream = inputStream.pipe(require('tar').Parse())
  tarStream.on 'error', callback
  tarStream.on 'entry', (entry) -> paths.push(entry.props.path)
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
      contents = []
      entry.on 'data', (data) -> contents.push(data)
      entry.on 'end', -> callback(null, Buffer.concat(contents).toString())
    else
      entry.autodrain()

readFileFromGzip = (archivePath, filePath, callback) ->
  if path.extname(path.basename(archivePath, '.gz')) isnt '.tar'
    callback("'#{path.extname(filePath)}' files are not supported")
    return

  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', callback
  gzipStream = fileStream.pipe(require('zlib').createGunzip())
  gzipStream.on 'error', callback
  gzipStream.on 'end', ->
    callback("#{filePath} does not exist in the archive: #{archivePath}")
  readFileFromTarStream(gzipStream, filePath, callback)

readFileFromTar = (archivePath, filePath, callback) ->
  fileStream = fs.createReadStream(archivePath, callback)
  fileStream.on 'error', callback
  fileStream.on 'end', ->
    callback("#{filePath} does not exist in the archive: #{archivePath}")
  readFileFromTarStream(fileStream, filePath, callback)

readFileFromTarStream = (inputStream, filePath, callback) ->
  tar = require 'tar'
  tarStream = inputStream.pipe(tar.Parse())

  tarStream.on 'error', callback
  tarStream.on 'entry', (entry) ->
    return unless filePath is entry.props.path

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

  readFile: (archivePath, filePath, callback) ->
    switch path.extname(archivePath)
      when '.tar' then readFileFromTar(archivePath, filePath, wrapCallback(callback))
      when '.gz' then readFileFromGzip(archivePath, filePath, wrapCallback(callback))
      when '.zip' then readFileFromZip(archivePath, filePath, wrapCallback(callback))
      else callback(new Error("'#{path.extname(archivePath)}' files are not supported"))
