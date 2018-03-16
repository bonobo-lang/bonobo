part of bonobo.src.analysis;

class BonoboModuleSystem {
  final Directory rootDirectory;
  BonoboModule _rootModule;

  BonoboModuleSystem._(this.rootDirectory, BonoboModule coreLibrary) {
    _rootModule = new BonoboModule._(rootDirectory, coreLibrary);
  }

  static Future<BonoboModuleSystem> create(Directory rootDirectory) async {
    var core = await _createCore();
    return new BonoboModuleSystem._(rootDirectory, core);
  }

  static Future<BonoboModule> _createCore() async {
    // First up is the core library. This contains crucial data types, like `String` and `Num`.
    var core = new BonoboModule._core(null, null);

    // Within core exist all the "global" libraries.
    // TODO: Third-party libs?

    // The local module also exists within the global context.

    return core;
  }

  FileSystem get fileSystem => rootDirectory.fileSystem;

  BonoboModule get rootModule => _rootModule;

  Future<BonoboModule> createModule(
      Directory directory, BonoboModule parent) async {
    // Find all .bnb files
    var sourceFiles = await directory
        .list()
        .where((e) => e is File && p.extension(e.path) == '.bnb')
        .cast<File>()
        .toList();

    // TODO: Parse files here, instead of on-the-fly in the language server.
    var module = new BonoboModule._(directory, parent);

    for (var sourceFile in sourceFiles) {
      module.compilationUnits[sourceFile.absolute.uri] = null;
    }

    return module;
  }

  Future<BonoboModule> findModuleForDirectory(
      Uri sourceUrl, BonoboModule parent) async {
    var dirPath = sourceUrl.toString(),
        rootDir = rootDirectory.absolute.uri.toString();

    if (p.equals(rootDir, dirPath)) return rootModule;

    if (!p.isWithin(rootDir, dirPath)) {
      return null;
    }

    var relativePath = p.relative(dirPath, from: rootDir);
    var parts = p.split(relativePath);

    // Now that we've produced a relative path, walk through the module tree.
    // If a module does not exist, it must be produced.

    BonoboModule module = rootModule;

    for (var part in parts) {
      var name = p.basenameWithoutExtension(part);
      var child =
          module.children.firstWhere((m) => m.name == name, orElse: () => null);

      if (child == null) {
        // If no such module exists, then first resolve a directory.
        var dir = module.directory.childDirectory(part);

        // If it doesn't exist, then return `null`.
        // The analyzer, compiler, etc. are responsible for handling this.
        if (!await dir.exists()) {
          return null;
        }

        child = await createModule(dir, parent);
        module.children.add(child);
      }

      module = child;
    }

    return module;
  }

  Future<BonoboModule> findModuleForFile(
      Uri sourceUrl, BonoboModule parent) async {
    return findModuleForDirectory(
        Uri.parse(p.dirname(sourceUrl.toString())), parent);
  }
}
