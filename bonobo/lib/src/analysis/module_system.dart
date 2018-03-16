part of bonobo.src.analysis;

class BonoboModuleSystem {
  final Directory rootDirectory;
  BonoboModule _rootModule;

  BonoboModuleSystem._(this.rootDirectory, BonoboModule coreLibrary) {
    _rootModule = new BonoboModule._(rootDirectory, coreLibrary, this);
  }

  static Future<BonoboModuleSystem> create(Directory rootDirectory) async {
    var core = await _createCore();
    var system = new BonoboModuleSystem._(rootDirectory, core);

    // Analyze the root module
    //var analyzer = system._rootModule.analyzer = new BonoboAnalyzer(system);
    //analyzer.module = system._rootModule;
    //system._rootModule = await system.createModule(rootDirectory, null);

    return system;
  }

  static Future<BonoboModule> _createCore() async {
    // First up is the core library. This contains crucial data types, like `String` and `Num`.
    var core = new BonoboModule._core(null, null);

    // Within core exist all the "global" libraries.
    core.types.addAll({
      BonoboType.Num.name: BonoboType.Num,
      BonoboType.String$.name: BonoboType.String$,
    });

    // TODO: Third-party libs?

    // The local module also exists within the global context.

    return core;
  }

  FileSystem get fileSystem => rootDirectory.fileSystem;

  BonoboModule get rootModule => _rootModule;

  Future analyzeModule(
      BonoboModule module, Directory directory, BonoboModule parent) async {
    // TODO: Provide some way to invalidate the module
    if (module.analyzer != null) return;

    // Find all .bnb files
    var sourceFiles = await directory
        .list()
        .where((e) => e is File && p.extension(e.path) == '.bnb')
        .cast<File>()
        .toList();
    var analyzer = module.analyzer ??= new BonoboAnalyzer(this);

    for (var sourceFile in sourceFiles) {
      //print('Start ${sourceFile.absolute.uri}...');
      // Parse files here, instead of on-the-fly in the language server.
      var scanner = new Scanner(await sourceFile.readAsString(),
          sourceUrl: sourceFile.absolute.uri)
        ..scan();
      module.emptySpan ??= scanner.emptySpan;
      var parser = new Parser(scanner);
      var compilationUnit = parser.parseCompilationUnit();

      // TODO: Analyze???
      await analyzer.analyze(
        compilationUnit,
        scanner.scanner.sourceUrl,
        parser,
        module,
      );

      module..compilationUnits[sourceFile.absolute.uri] = compilationUnit;
    }
  }

  Future<BonoboModule> createModule(
      Directory directory, BonoboModule parent) async {
    var module = new BonoboModule._(directory, parent, this);
    await analyzeModule(module, directory, parent);
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
