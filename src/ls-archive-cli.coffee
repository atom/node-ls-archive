path = require 'path'
optimist = require 'optimist'
async = require 'async'
archive = require './ls-archive'

module.exports = ->
  files = optimist.usage('Usage: lsa [file ...]') .demand(1).argv._
  queue = async.queue (archivePath, callback) ->
    do (archivePath) ->
      archive.list archivePath, (error, files) ->
        if error?
          console.error("Error reading: #{archivePath}")
        else
          console.log("#{archivePath} (#{files.length})")
          for file, index in files
            if index is files.length - 1
              prefix = '\u2514\u2500\u2500 '
            else
              prefix = '\u251C\u2500\u2500 '
            console.log "#{prefix}#{file.getPath()}"
          console.log()
        callback()

  files.forEach (file) -> queue.push(path.resolve(process.cwd(), file))
