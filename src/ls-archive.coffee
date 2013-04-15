fs = require 'fs'
path = require 'path'

listZip = (archivePath, callback) ->
  unzip = require 'unzip'
  paths = []
  fileStream = fs.createReadStream(archivePath)
  zipStream = fileStream.pipe(unzip.Parse())
  zipStream.on 'entry', (entry) ->
    paths.push(entry.path)
    entry.autodrain()
  zipStream.on 'close', -> callback(paths)

listGzip = (archivePath, callback) ->
  if path.extname(path.basename(archivePath, '.gz')) isnt '.tar'
    callback([])
    return

  zlib = require 'zlib'
  gzipStream = fs.createReadStream(archivePath).pipe(zlib.createGunzip())
  readTarStream(gzipStream, callback)

listTar = (archivePath, callback) ->
  fileStream = fs.createReadStream(archivePath)
  readTarStream(fileStream, callback)

readTarStream = (inputStream, callback) ->
  tar = require 'tar'
  paths = []
  tarStream = inputStream.pipe(tar.Parse())
  tarStream.on 'entry', (entry) -> paths.push(entry.props.path)
  tarStream.on 'end', -> callback(paths)

createReadStream = (archivePath, callback) ->
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', (error) -> callback(error)
  fileStream

readFileFromZip = (archivePath, filePath, callback) ->
  unzip = require 'unzip'
  fileStream = createReadStream(archivePath, callback)
  filePathFound = false
  zipStream = fileStream.pipe(unzip.Parse())
  zipStream.on 'entry', (entry) ->
    if not filePathFound and filePath is entry.path
      contents = []
      entry.on 'data', (data) -> contents.push(data)
      entry.on 'end', ->
        filePathFound = true
        callback(null, Buffer.concat(contents).toString())
    else
      entry.autodrain()
  zipStream.on 'close', ->
    unless filePathFound
      callback(new Error("#{filePath} does not exist in the archive: #{archivePath}"))

readFileFromGzip = (archivePath, filePath, callback) ->
  if path.extname(path.basename(archivePath, '.gz')) isnt '.tar'
    callback(null, '')
    return

  zlib = require 'zlib'
  fileStream = createReadStream(archivePath, callback)
  gzipStream = fileStream.pipe(zlib.createGunzip())
  readFileFromTarStream(gzipStream, archivePath, filePath, callback)

readFileFromTar = (archivePath, filePath, callback) ->
  fileStream = createReadStream(archivePath, callback)
  readFileFromTarStream(fileStream, archivePath, filePath, callback)

readFileFromTarStream = (inputStream, archivePath, filePath, callback) ->
  tar = require 'tar'
  tarStream = inputStream.pipe(tar.Parse())

  filePathFound = false
  tarStream.on 'entry', (entry) ->
    return if filePathFound
    return unless filePath is entry.props.path

    contents = []
    entry.on 'data', (data) -> contents.push(data)
    entry.on 'end', ->
      filePathFound = true
      callback(null, Buffer.concat(contents).toString())
  tarStream.on 'end', ->
    unless filePathFound
      callback(new Error("#{filePath} does not exist in the archive: #{archivePath}"))

module.exports =
  list: (archivePath, callback) ->
    switch path.extname(archivePath)
      when '.tar' then listTar(archivePath, callback)
      when '.gz' then listGzip(archivePath, callback)
      when '.zip' then listZip(archivePath, callback)
      else callback([])

  readFile: (archivePath, filePath, callback) ->
    switch path.extname(archivePath)
      when '.tar' then readFileFromTar(archivePath, filePath, callback)
      when '.gz' then readFileFromGzip(archivePath, filePath, callback)
      when '.zip' then readFileFromZip(archivePath, filePath, callback)
