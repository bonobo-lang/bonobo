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
        allowed: ['c', 'bvm', 'x86'],
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

    if (argResults['target'] == 'c' || argResults['target'] == 'x86')
      return runCCompiler(analyzer);
    else if (argResults['target'] == 'bvm')
      return await runBVMCompiler(analyzer);

    throw 'Unsupported compile target: ${argResults['target']}';
  }

  runBVMCompiler(BonoboAnalyzer analyzer) async {
    var tuple = await ssaCompiler.compile(analyzer.module, analyzer.errors);
    var program = tuple.item1, state = tuple.item2;

    var errors =
        state.errors.where((e) => e.severity == BonoboErrorSeverity.error);
    var warnings =
        state.errors.where((e) => e.severity == BonoboErrorSeverity.warning);

    printErrors(errors);
    printErrors(warnings);

    if (errors.isNotEmpty || (argResults['strict'] && warnings.isNotEmpty)) {
      stderr.writeln('Compilation finished with errors.');
      exitCode = 1;
      return null;
    }

    var binarySink = new BinarySink();
    const BytecodeGenerator().generate(program, state, binarySink);
    var bytecode = binarySink.toBytes();

    /*
    for (int i = 0; i < bytecode.length; i++) {
      print('0x${i.toRadixString(16)}: 0x${bytecode[i].toRadixString(16)}');
    }*/

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

    if (sink != stdout) await sink.close();
  }

  runBVMCompilerOld(BonoboAnalyzer analyzer) async {
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

    if (argResults['target'] == 'c') {
      getOutput(this)
        ..write(buf)
        ..close();
    } else {
      // Resolve include paths, etc.
      var tccDir = await resolveUri(Uri.parse('package:bonobo/bvm/src/tcc'))
          .then((u) => u.toFilePath());
      var cDir = await resolveUri(Uri.parse('package:bonobo/runtime'))
          .then((u) => u.toFilePath());

      var data = compileC(buf.toString(), true, [
        p.join(tccDir, 'include'),
        p.join(cDir, 'include'),
      ]);

      /*getOutput(this)
        ..add(data)
        ..close();

      if (!Platform.isWindows && argResults.wasParsed('out')) {
        var chmod = await Process.run('chmod', ['+x', argResults['out']]);
        if (chmod.exitCode != 0) throw 'chmod +x failed.';
      }*/
    }
  }
}
