fs = require 'fs'
path = require 'path'

wrapCallback = (callback) ->
  called = false
  (error, data) ->
    unless called
      called = true
      callback(error, data)

listZip = (archivePath, callback) ->
  unzip = require 'unzip'
  paths = []
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', (error) -> callback(error)
  fileStream.on 'end', -> callback(null, paths)
  zipStream = fileStream.pipe(unzip.Parse())
  zipStream.on 'error', (error) -> callback(error)
  zipStream.on 'entry', (entry) ->
    paths.push(entry.path)
    entry.autodrain()

listGzip = (archivePath, callback) ->
  if path.extname(path.basename(archivePath, '.gz')) isnt '.tar'
    callback([])
    return

  zlib = require 'zlib'
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', (error) -> callback(error)
  gzipStream = fileStream.pipe(zlib.createGunzip())
  gzipStream.on 'error', (error) -> callback(error)
  readTarStream(gzipStream, callback)

listTar = (archivePath, callback) ->
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', (error) -> callback(error)
  readTarStream(fileStream, callback)

readTarStream = (inputStream, callback) ->
  tar = require 'tar'
  paths = []
  tarStream = inputStream.pipe(tar.Parse())
  tarStream.on 'error', (error) -> callback(error)
  tarStream.on 'entry', (entry) -> paths.push(entry.props.path)
  tarStream.on 'end', -> callback(null, paths)

readFileFromZip = (archivePath, filePath, callback) ->
  unzip = require 'unzip'
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', (error) -> callback(error)
  fileStream.on 'end', ->
    callback(new Error("#{filePath} does not exist in the archive: #{archivePath}"))
  zipStream = fileStream.pipe(unzip.Parse())
  zipStream.on 'error', (error) -> callback(error)
  zipStream.on 'entry', (entry) ->
    if filePath is entry.path
      contents = []
      entry.on 'data', (data) -> contents.push(data)
      entry.on 'end', -> callback(null, Buffer.concat(contents).toString())
    else
      entry.autodrain()

readFileFromGzip = (archivePath, filePath, callback) ->
  if path.extname(path.basename(archivePath, '.gz')) isnt '.tar'
    callback(new Error("'#{path.extname(filePath)}' files are not supported"))
    return

  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', (error) -> callback(error)
  zlib = require 'zlib'
  gzipStream = fileStream.pipe(zlib.createGunzip())
  gzipStream.on 'error', (error) -> callback(error)
  gzipStream.on 'end', ->
    callback(new Error("#{filePath} does not exist in the archive: #{archivePath}"))
  readFileFromTarStream(gzipStream, filePath, callback)

readFileFromTar = (archivePath, filePath, callback) ->
  fileStream = fs.createReadStream(archivePath, callback)
  fileStream.on 'error', (error) -> callback(error)
  fileStream.on 'end', ->
    callback(new Error("#{filePath} does not exist in the archive: #{archivePath}"))
  readFileFromTarStream(fileStream, filePath, callback)

readFileFromTarStream = (inputStream, filePath, callback) ->
  tar = require 'tar'
  tarStream = inputStream.pipe(tar.Parse())

  tarStream.on 'error', (error) -> callback(error)
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
