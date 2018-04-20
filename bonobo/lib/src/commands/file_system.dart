part of bonobo.src.commands;

class BonoboFileSystem extends ForwardingFileSystem {
  File bonoboYaml;
  final Logger logger;

  BonoboFileSystem(FileSystem localFileSystem, Uri currentFile,
      BonoboLanguageServer languageServer, this.logger)
      : super(new MemoryFileSystem()) {
    // First, find a bonobo.yaml file.

    // Start from the directory where the file resides, and go upwards.
    var file = localFileSystem.file(currentFile);
    // var logFile = file.parent.childFile('log.txt')..createSync(recursive: true);
    // var logSink = logFile.openWrite(mode: FileMode.APPEND);
    var rootPrefix = path.toUri(path.rootPrefix(file.absolute.path));
    var dir = path.toUri(path.dirname(file.absolute.path));

    while (dir != rootPrefix) {
      try {
        //logSink.writeln('Hm: $dir');
        var bonoboYamlFile = localFileSystem.file(dir.resolve('bonobo.yaml'));

        if (bonoboYamlFile.existsSync()) {
          bonoboYaml = bonoboYamlFile;
          break;
        } else {
          dir = path.toUri(path.dirname(dir.path));
        }
      } catch (_) {
        break;
      }
    }

    //logSink.writeln('DIR: $dir');
    Uri cDir;

    if (bonoboYaml == null) {
      // If no `bonobo.yaml` file was found, default to the current directory.
      cDir = file.parent.absolute.uri;

      /*
      languageServer._diagnostics.add(new lsp.Diagnostics((b) {
        b
          ..uri = currentFile.toString()
          ..diagnostics = [
            new lsp.Diagnostic((b) {
              b
                ..message = ""
                ..severity = 1
                ..source = 'pingaaaa'
                ..range = new lsp.Range((b) {
                  b.start = b.end = new lsp.Position((b) {
                    b
                      ..line = 1
                      ..character = 0;
                  });
                });
            })
          ];
      }));*/
    } else {
      // Now that we've found our root directory, switch!
      cDir = bonoboYaml.parent.absolute.uri;
    }

    //logSink.writeln('CUR: $cDir');
    logger.config('New Bonobo file system created in ${currentDirectory.path}');
    directory(cDir).createSync(recursive: true);
    currentDirectory = cDir.path;

    void copyDirectory(Directory from, Directory to) {
      for (var entity in from.listSync()) {
        if (entity is File) {
          var outFile = to.childFile(path.basename(entity.path))
            ..createSync(recursive: true)
            ..writeAsBytesSync(entity.readAsBytesSync());
          logger.fine('Copied file to $outFile');
        } else if (entity is Link) {
          var outLink = to.childLink(path.basename(entity.path))
            ..createSync(entity.resolveSymbolicLinksSync(), recursive: true);
          logger.fine('Copied file to $outLink');
        } else if (entity is Directory) {
          var outDir = to.childDirectory(path.basename(entity.path))
            ..createSync(recursive: true);
          copyDirectory(entity, outDir);
          logger.fine('Copied dir to $outDir');
        }
      }
    }

    copyDirectory(localFileSystem.directory(cDir), directory(dir));
    //logSink.close();
  }
}
