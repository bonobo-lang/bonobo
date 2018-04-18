part of bonobo.src.commands;

class CompileCommand extends BonoboCommand {
  final String name = 'compile';
  final String description = 'Compiles Bonobo source code into C.';

  CompileCommand() : super() {
    argParser.addFlag(
      'strict',
      abbr: 's',
      help: 'Treat warnings as errors.',
      defaultsTo: false,
      negatable: false,
    );
  }

  CompileOptions validate() {
    String filename = 'main.bnb';

    if (!argResults.rest.isEmpty) {
      filename = argResults.rest.first;
    }

    return new CompileOptions(filename: filename);
  }

  @override
  run() async {
    var analyzer = await analyze(validate());
    var compiler = new BonoboCCompiler(analyzer);
    await compiler.compile();

    var errors =
        compiler.errors.where((e) => e.severity == BonoboErrorSeverity.error);
    var warnings =
        compiler.errors.where((e) => e.severity == BonoboErrorSeverity.warning);

    printErrors(errors);
    printErrors(warnings);

    if (errors.isNotEmpty || (argResults['strict'] && warnings.isNotEmpty)) {
      stderr.writeln('Compilation finished with errors.');
      exitCode = 1;
      return null;
    }

    var buf = new CodeBuffer();
    compiler.output.generate(buf);
    getOutput(this)
      ..write(buf)
      ..close();
  }
}
