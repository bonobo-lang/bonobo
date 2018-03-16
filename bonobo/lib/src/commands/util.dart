part of bonobo.src.commands;

Future<Tuple2<String, Uri>> getInput(Command command) async {
  String contents;
  Uri sourceUrl;

  if (command.argResults.rest.isEmpty) {
    stderr.writeln('fatal error: no input file');
    exitCode = 1;
    return null;
  }

  if (command.argResults.rest[0] == '-') {
    contents = await stdin.transform(UTF8.decoder).join();
    sourceUrl = Uri.parse('<stdin>');
  } else {
    var file = new io.File(command.argResults.rest[0]);
    contents = await file.readAsString();
    sourceUrl = file.absolute.uri;
  }

  return new Tuple2(contents, sourceUrl);
}

IOSink getOutput(BonoboCommand command) {
  if (command.argResults.wasParsed('out')) {
    return new io.File(command.argResults['out']).openWrite();
  } else {
    return stdout;
  }
}

Future<Tuple3<Scanner, Parser, CompilationUnitContext>> scanAndParse(
    Command command) async {
  var input = await getInput(command);
  if (input == null) return null;
  var contents = input.item1, sourceUrl = input.item2;
  var scanner = new Scanner(contents, sourceUrl: sourceUrl)..scan();
  var parser = new Parser(scanner);
  var compilationUnit = parser.parseCompilationUnit();
  return new Tuple3(scanner, parser, compilationUnit);
}

Future<BonoboAnalyzer> analyze(Command command) async {
  var tuple = await scanAndParse(command);
  if (tuple == null) return null;
  const fs = const LocalFileSystem();
  var directory = fs.directory(fs.currentDirectory);
  var moduleSystem = await BonoboModuleSystem.create(directory);
  var module = await moduleSystem.findModuleForFile(
      tuple.item1.scanner.sourceUrl, moduleSystem.rootModule);
  await moduleSystem.analyzeModule(module, directory, moduleSystem.rootModule);
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
