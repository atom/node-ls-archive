fs = require 'fs'
path = require 'path'

module.exports =
  list: (archivePath, callback) ->
    switch path.extname(archivePath)
      when '.tar' then @listTar(archivePath, callback)
      when '.gz' then @listGzip(archivePath, callback)
      when '.zip' then @listZip(archivePath, callback)
      else callback([])

  listZip: (archivePath, callback) ->
    unzip = require 'unzip'
    paths = []
    fileStream = fs.createReadStream(archivePath)
    zipStream = fileStream.pipe(unzip.Parse())
    zipStream.on 'entry', (entry) ->
      paths.push(entry.path)
      entry.autodrain()
    zipStream.on 'close', -> callback(paths)

  listGzip: (archivePath, callback) ->
    if path.extname(path.basename(archivePath, '.gz')) isnt '.tar'
      callback([])
      return

    zlib = require 'zlib'
    gzipStream = fs.createReadStream(archivePath).pipe(zlib.createGunzip())
    @readTarStream(gzipStream, callback)

  listTar: (archivePath, callback) ->
    fileStream = fs.createReadStream(archivePath)
    @readTarStream(fileStream, callback)

  readTarStream: (inputStream, callback) ->
    tar = require 'tar'
    paths = []
    tarStream = inputStream.pipe(tar.Parse())
    tarStream.on 'entry', (entry) -> paths.push(entry.props.path)
    tarStream.on 'end', -> callback(paths)

  readFile: (archivePath, filePath, callback) ->
    switch path.extname(archivePath)
      when '.tar' then @readFileFromTar(archivePath, filePath, callback)

  readFileFromTar: (archivePath, filePath, callback) ->
    fileStream = fs.createReadStream(archivePath)
    fileStream.on 'error', (error) -> callback(error)

    tar = require 'tar'
    tarStream = fileStream.pipe(tar.Parse())

    filePathFound = false
    tarStream.on 'entry', (entry) ->
      return unless filePath is entry.props.path

      contents = new Buffer(entry.props.size)
      position = 0
      entry.on 'data', (data) ->
        position += data.copy(contents, 0, position)
      entry.on 'end', ->
        filePathFound = true
        callback(null, contents.toString())
    tarStream.on 'end', ->
      unless filePathFound
        callback(new Error("#{filePath} does not exist in the archive: #{archivePath}"))
