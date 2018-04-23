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
      BonoboType.Byte.name: BonoboType.Byte,
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
      BonoboModule module, Directory directory, BonoboModule parent,
      {bool fresh: false}) async {
    if (fresh) {
      // Invalidate existing module
      module._scope = new SymbolTable();
      module.analyzer?.errors?.clear();
      module.types.clear();
    }

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
    if (directory == parent?.directory) return parent;

    var module = new BonoboModule._(directory, parent, this);

    // Crawl subdirs
    await for (var entity in directory.list(recursive: false)) {
      if (entity is Directory) {
        if (entity != module.directory) {
          var name = p.basename(entity.path);
          if (!module.children.any((m) => m.name == name))
            await createModule(entity, module);
        }
      }
    }

    await analyzeModule(module, directory, parent);
    return module;
  }

  Future<BonoboModule> findModuleForDirectory(
      Uri sourceUrl, BonoboModule parent) async {
    var dirPath = sourceUrl.toString(),
        rootDir = rootDirectory.absolute.uri.toString();

    if (p.equals(rootDir, dirPath)) {
      // TODO: Is the right way click invalidation?
      if (_rootModule.analyzer != null &&
          _rootModule.compilationUnits[sourceUrl] != null) {
        print('old root $rootDir');
        return _rootModule;
      }
      return _rootModule = await createModule(rootDirectory, null);
    }

    if (!p.isWithin(rootDir, dirPath)) {
      //print('Could not find $dirPath within $rootDir');
      //print('Check the root? ${rootDirectory}');
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
        //module.children.add(child);
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

  void dumpTree([BonoboModule module]) {
    var b = new StringBuffer()..writeln('Dump of module "${module.fullName}":');

    void prinDent(int indent, [int n = 1]) {
      for (int i = 0; i < n; i++) {
        for (int j = 0; j < indent; j++) b.write('  ');
      }
    }

    void dump(BonoboModule module, int indent) {
      // Show names
      prinDent(indent);
      b.writeln('* ${module.name} (${module.directory.path})');

      // Dump children
      prinDent(indent + 1);
      b.writeln('* Children: ${module.children.length}');
      module.children.forEach((m) => dump(m, indent + 2));

      // Print all types
      prinDent(indent + 1);
      b.writeln('* Types: ${module.types.length}');

      module.types.forEach((name, type) {
        prinDent(indent + 2);
        b.writeln('* $name: $type');
      });

      // Print all public symbols
      var publicSymbols = module.scope.allPublicVariables;
      prinDent(indent + 1);
      b.writeln('* Public Variables: ${publicSymbols.length}');

      publicSymbols.forEach((symbol) {
        prinDent(indent + 2);
        b.writeln('* ${symbol.name}: ${symbol.value}');
      });
    }

    dump(module ?? rootModule, 0);
    print(b);
  }
}
