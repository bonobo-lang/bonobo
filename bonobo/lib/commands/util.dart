part of bonobo.src.commands;

class CompilerInput {
  final Uri uri;

  final String contents;

  const CompilerInput(this.uri, this.contents);

  static Future<CompilerInput> fromOptions(CompileOptions options) async {
    String contents;
    Uri sourceUrl;

    if (options.filename == '-') {
      contents = await stdin.transform(utf8.decoder).join();
      sourceUrl = Uri.parse('<stdin>');
    } else {
      var file = new io.File(options.filename);

      if(!await file.exists()) {
        throw new Exception('Source file not found: ${options.filename}');
      }

      contents = await file.readAsString();
      sourceUrl = file.absolute.uri;
    }

    return new CompilerInput(sourceUrl, contents);
  }
}

class CompileOptions {
  final String filename;

  const CompileOptions({this.filename: 'main.bnb'});
}

IOSink getOutput(BonoboCommand command) {
  if (command.argResults.wasParsed('out')) {
    return new io.File(command.argResults['out']).openWrite();
  } else {
    return stdout;
  }
}

Future<Tuple3<Scanner, Parser, CompilationUnitContext>> scanAndParse(
    CompileOptions options) async {
  CompilerInput input = await CompilerInput.fromOptions(options);
  var scanner = new Scanner(input.contents, sourceUrl: input.uri)..scan();
  var parser = new Parser(scanner);
  var compilationUnit = parser.parseCompilationUnit();
  return new Tuple3(scanner, parser, compilationUnit);
}

Future<BonoboAnalyzer> analyze(CompileOptions options) async {
  var tuple = await scanAndParse(options);
  const fs = const LocalFileSystem();
  var directory = fs.directory(fs.currentDirectory);
  var moduleSystem = await BonoboModuleSystem.create(directory);
  var module = await moduleSystem.findModuleForFile(
      tuple.item1.scanner.sourceUrl, moduleSystem.rootModule);
  //await moduleSystem.analyzeModule(module, directory, moduleSystem.rootModule);
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
