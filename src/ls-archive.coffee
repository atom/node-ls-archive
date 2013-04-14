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
    zipStream.on 'close', ->
      callback(paths)

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
    tarStream.on 'entry', (e) -> paths.push(e.props.path)
    tarStream.on 'end', -> callback(paths)
