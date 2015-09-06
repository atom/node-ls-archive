# Node Ls Archive Module [![Build Status](https://travis-ci.org/atom/node-ls-archive.png)](https://travis-ci.org/atom/node-ls-archive)

List or read the files and folders inside archive files.

Supported file extensions:

  * .epub
  * .jar
  * .love
  * .nupkg
  * .tar
  * .tar.gz
  * .tgz
  * .war
  * .zip
  * .egg
  * .whl
  * .xpi

## Installing

```sh
npm install ls-archive
```

## Building
  * Clone the repository
  * Run `npm install`
  * Run `grunt` to compile CoffeeScript code
  * Run `grunt test` to run the specs

## Using

```coffeescript
archive = require 'ls-archive'
```

### archive.list(archivePath, callback)

List the files and folders inside the archive file path. The `callback` gets
two arguments `(error, archiveEntries)`.

`archivePath` - The string path to the archive file.

`callback` - The function to call after reading completes with an error or
an array of [ArchiveEntry](#archiveentry) objects.

### archive.read(archivePath, filePath, callback)

Read the contents of the file path in the archive path and invoke the callback
with those contents. The `callback` gets two arguments
`(error, filePathContents)`.

`archivePath` - The string path to the archive file.

`filePath` - The string path inside the archive to read.

`callback` - The function to call after reading completes with an error or
the Buffer contents.

### archive.readGzip(gzipArchivePath, callback)

Read the contents of the gzipped archive path and invoke the callback with the
Buffer contents of the uncompressed paths.  The `callback` gets two arguments
`(error, pathContents)`.

`gzipArchivePath` - The string path to the gzipped archive file.

`callback` - The function to call after reading completes with an error or
the Buffer contents.

### ArchiveEntry

Class representing a path entry inside an archive file.

#### .isFile()
Is the entry a file?

Returns `true` if a file, `false` otherwise.

#### .isFolder()
Is the entry a folder?

Returns `true` if a folder, `false` otherwise.

#### .isSymbolicLink()
Is the entry a symbolic link?

Returns `true` if a symbolic link, `false` otherwise.

#### .getPath()
Get the path of this entry.

Returns the string path.
