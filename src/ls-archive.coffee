fs = require 'fs'
path = require 'path'

listZip = (archivePath, callback) ->
  unzip = require 'unzip'
  paths = []
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'end', -> callback(paths)
  zipStream = fileStream.pipe(unzip.Parse())
  zipStream.on 'entry', (entry) ->
    paths.push(entry.path)
    entry.autodrain()

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

readFileFromZip = (archivePath, filePath, callback) ->
  unzip = require 'unzip'
  filePathFound = false
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', (error) -> callback(error) unless filePathFound
  fileStream.on 'end', ->
    unless filePathFound
      callback(new Error("#{filePath} does not exist in the archive: #{archivePath}"))
  zipStream = fileStream.pipe(unzip.Parse())
  zipStream.on 'error', (error) -> callback(error) unless filePathFound
  zipStream.on 'entry', (entry) ->
    if not filePathFound and filePath is entry.path
      contents = []
      entry.on 'data', (data) -> contents.push(data)
      entry.on 'end', ->
        filePathFound = true
        callback(null, Buffer.concat(contents).toString())
    else
      entry.autodrain()

readFileFromGzip = (archivePath, filePath, callback) ->
  if path.extname(path.basename(archivePath, '.gz')) isnt '.tar'
    callback(new Error("'#{path.extname(filePath)}' files are not supported"))
    return

  filePathFound = false
  fileStream = fs.createReadStream(archivePath)
  fileStream.on 'error', (error) -> callback(error) unless filePathFound
  fileStream.on 'end', ->
    unless filePathFound
      callback(new Error("#{filePath} does not exist in the archive: #{archivePath}"))
  zlib = require 'zlib'
  gzipStream = fileStream.pipe(zlib.createGunzip())
  gzipStream.on 'error', (error) -> callback(error) unless filePathFound
  fileCallback = (error, buffer) ->
    if error?
      callback(error)
    else
      filePathFound = true
      callback(null, buffer.toString())
  readFileFromTarStream(gzipStream, filePath, fileCallback)

readFileFromTar = (archivePath, filePath, callback) ->
  filePathFound = false
  fileStream = fs.createReadStream(archivePath, callback)
  fileStream.on 'error', (error) -> callback(error) unless filePathFound
  fileStream.on 'end', ->
    unless filePathFound
      callback(new Error("#{filePath} does not exist in the archive: #{archivePath}"))
  fileCallback = (error, buffer) ->
    if error?
      callback(error)
    else
      filePathFound = true
      callback(null, buffer.toString())
  readFileFromTarStream(fileStream, filePath, fileCallback)

readFileFromTarStream = (inputStream, filePath, callback) ->
  tar = require 'tar'
  tarStream = inputStream.pipe(tar.Parse())

  filePathFound = false
  tarStream.on 'error', (error) -> callback(error) unless filePathFound
  tarStream.on 'entry', (entry) ->
    return if filePathFound
    return unless filePath is entry.props.path

    contents = []
    entry.on 'data', (data) -> contents.push(data)
    entry.on 'end', ->
      filePathFound = true
      callback(null, Buffer.concat(contents).toString())

module.exports =
  list: (archivePath, callback) ->
    switch path.extname(archivePath)
      when '.tar' then listTar(archivePath, callback)
      when '.gz' then listGzip(archivePath, callback)
      when '.zip' then listZip(archivePath, callback)
      else callback(new Error("'#{path.extname(archivePath)}' files are not supported"))

  readFile: (archivePath, filePath, callback) ->
    switch path.extname(archivePath)
      when '.tar' then readFileFromTar(archivePath, filePath, callback)
      when '.gz' then readFileFromGzip(archivePath, filePath, callback)
      when '.zip' then readFileFromZip(archivePath, filePath, callback)
      else callback(new Error("'#{path.extname(archivePath)}' files are not supported"))
