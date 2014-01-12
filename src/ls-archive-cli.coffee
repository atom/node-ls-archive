path = require 'path'
async = require 'async'
colors = require 'colors'
optimist = require 'optimist'
archive = require './ls-archive'

module.exports = ->
  cli = optimist.usage( """
      Usage: lsa [file ...]

      List the files and folders inside an archive file.

      Supports .zip, .tar, .tar.gz, and .tgz files.
    """)
    .describe('colors', 'Enable colored output').default('colors', true).boolean('colors')
    .describe('help', 'Show this message').alias('h', 'help')
    .demand(1)

  if cli.argv.help
    cli.showHelp()
    return

  unless cli.argv.colors
    colors.setTheme
      cyan: 'stripColors'
      red: 'stripColors'

  queue = async.queue (archivePath, callback) ->
    do (archivePath) ->
      archive.list archivePath, (error, files) ->
        if error?
          console.error("Error reading: #{archivePath}".red)
        else
          console.log("#{archivePath.cyan} (#{files.length})")
          for file, index in files
            if index is files.length - 1
              prefix = '\u2514\u2500\u2500 '
            else
              prefix = '\u251C\u2500\u2500 '
            console.log "#{prefix}#{file.getPath()}"
          console.log()
        callback()

  files = cli.argv._
  files.forEach (file) -> queue.push(path.resolve(process.cwd(), file))
