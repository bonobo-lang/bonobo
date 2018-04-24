part of bonobo.src.commands;

class CompileCommand extends BonoboCommand {
  final String name = 'compile';
  final String description = 'Compiles Bonobo source code.';

  CompileCommand() : super() {
    argParser
      ..addFlag(
        'strict',
        abbr: 's',
        help: 'Treat warnings as errors.',
        defaultsTo: false,
        negatable: false,
      )
      ..addOption(
        'target',
        abbr: 't',
        help: 'The target platform to compile for.',
        defaultsTo: 'c',
        allowed: ['c', 'bvm'],
      );
  }

  @override
  run() async {
    var analyzer = await analyze(this);
    var errors =
        analyzer.errors.where((e) => e.severity == BonoboErrorSeverity.error);
    var warnings =
        analyzer.errors.where((e) => e.severity == BonoboErrorSeverity.warning);

    printErrors(errors);
    printErrors(warnings);

    if (errors.isNotEmpty || (argResults['strict'] && warnings.isNotEmpty)) {
      stderr.writeln('Compilation finished with errors.');
      exitCode = 1;
      return null;
    }

    if (argResults['target'] == 'c')
      return runCCompiler(analyzer);

    throw 'Unsupported compile target: ${argResults['target']}';
  }

  runCCompiler(BonoboAnalyzer analyzer) async {
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
