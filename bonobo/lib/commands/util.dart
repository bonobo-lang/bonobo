part of bonobo.src.commands;

IOSink getOutput(BonoboCommand command) {
  if (command.argResults.wasParsed('out')) {
    return new io.File(command.argResults['out']).openWrite();
  } else {
    return stdout;
  }
}

Future<Tuple3<Scanner, Parser, CompilationUnitContext>> scanAndParse(
    Command command) async {
  // Choose the first available *.bnb file
  io.File file;

  await for (var entity in io.Directory.current.list()) {
    if (entity is io.File && p.extension(entity.path) == '.bnb') {
      file = entity;
      break;
    }
  }

  if (file == null) throw 'No *.bnb files exist in the current directory.';

  var scanner = new Scanner(await file.readAsString(), sourceUrl: file.uri)
    ..scan();
  var parser = new Parser(scanner);
  var compilationUnit = parser.parseCompilationUnit();
  return new Tuple3(scanner, parser, compilationUnit);
}

Future<BonoboAnalyzer> analyze(Command command, {bool eager: true}) async {
  var tuple = await scanAndParse(command);
  const fs = const LocalFileSystem();
  var directory = fs.directory(fs.currentDirectory);
  var moduleSystem = await BonoboModuleSystem.create(directory);
  var module = await moduleSystem.findModuleForFile(
      tuple.item1.scanner.sourceUrl, moduleSystem.rootModule);
  await moduleSystem.analyzeModule(module, directory, moduleSystem.rootModule,
      lazy: !eager);
  return module.analyzer;
  /*
  var analyzer = new BonoboAnalyzer(
    tuple.item3,
    tuple.item2.scanner.scanner.sourceUrl,
    tuple.item2,
    moduleSystem,
  );
  await analyzer.analyze();*/
}

void printErrors(Iterable<BonoboError> errors) {
  for (var e in errors) {
    stderr
      ..write(severityToString(e.severity))
      ..write(': ')
      ..writeln(e);

    if (e.span != null) stderr.writeln(e.span.highlight());
  }
}
