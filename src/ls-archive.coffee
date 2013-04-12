fs = require 'fs'
path = require 'path'

module.exports =
  list: (archivePath, callback) ->
    switch path.extname(archivePath)
      when '.tar' then @listTar(archivePath, callback)
      when '.gz' then @listGzip(archivePath, callback)

      else callback([])

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
