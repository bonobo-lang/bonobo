part of bonobo.src.commands;

class CompileCommand extends BonoboCommand {
  final String name = 'compile';
  final String description = 'AOT-compiles Bonobo source code.';

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
        defaultsTo: 'bvm',
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
      stderr.writeln('Static analysis finished with errors.');
      exitCode = 1;
      return null;
    }

    if (argResults['target'] == 'c')
      return runCCompiler(analyzer);
    else if (argResults['target'] == 'bvm') return runBVMCompiler(analyzer);

    throw 'Unsupported compile target: ${argResults['target']}';
  }

  runBVMCompiler(BonoboAnalyzer analyzer) async {
    var compiler = new BVMCompiler();
    var bytecode = await compiler.compile(analyzer.module);

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

    IOSink sink;

    if (argResults.wasParsed('out') ||
        (argResults.rest.isEmpty || argResults.rest[0] != '-')) {
      var file = new io.File(argResults.wasParsed('out')
          ? argResults['out']
          : p.setExtension(p.basename(analyzer.module.name), '.b'));
      await file.create(recursive: true);
      sink = file.openWrite();
    } else {
      sink = stdout;
    }

    sink.add(bytecode);
    await sink.close();
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
