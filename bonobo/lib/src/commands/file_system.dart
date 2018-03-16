part of bonobo.src.commands;

class BonoboFileSystem extends ForwardingFileSystem {
  File bonoboYaml;

  BonoboFileSystem(FileSystem localFileSystem, Uri currentFile,
      BonoboLanguageServer languageServer)
      : super(new MemoryFileSystem()) {
    // First, find a bonobo.yaml file.

    // Start from the directory where the file resides, and go upwards.
    var file = localFileSystem.file(currentFile);
    var rootPrefix = path.rootPrefix(file.absolute.path);
    var dir = path.dirname(file.absolute.path);

    while (!path.equals(dir, rootPrefix)) {
      var bonoboYamlFile = localFileSystem.file(path.join(dir, 'bonobo.yaml'));

      if (bonoboYamlFile.existsSync()) {
        bonoboYaml = bonoboYamlFile;
        break;
      } else {
        dir = path.dirname(dir);
      }
    }

    if (bonoboYaml == null) {
      // If no `bonobo.yaml` file was found, default to the current directory.
      delegate.currentDirectory = file.parent.uri;

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
      delegate.currentDirectory = bonoboYaml.parent.uri;
    }
  }
}
