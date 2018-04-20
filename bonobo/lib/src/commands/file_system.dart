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

    void copyDirectory(Directory dir) {
      for (var entity in dir.listSync()) {
        if (entity is File) {
          this.file(entity.absolute.path)
            ..createSync(recursive: true)
            ..writeAsBytesSync(entity.readAsBytesSync());
        } else if (entity is Link) {
          this
              .link(entity.absolute.path)
              .createSync(entity.resolveSymbolicLinksSync(), recursive: true);
        } else if (entity is Directory) {
          this.directory(entity.absolute.path).createSync(recursive: true);
          copyDirectory(entity);
        }
      }
    }

    copyDirectory(localFileSystem.directory(cDir));
    //logSink.close();
  }
}
