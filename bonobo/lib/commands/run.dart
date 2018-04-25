part of bonobo.src.commands;

class RunCommand extends Command {
  String get name => 'run';

  String get description => 'JIT-compiles and runs a Bonobo module.';

  RunCommand() : super() {
    argParser.addFlag(
      'strict',
      abbr: 's',
      help: 'Treat warnings as errors.',
      defaultsTo: false,
      negatable: false,
    );
  }

  @override
  run() async {
    var analyzer = await analyze(this, eager: false);

    // Create a new BVM.
    var bvm = new BVM();

    // Find the main function.
    var mainFunction = analyzer.module.mainFunction;

    if (mainFunction == null)
      throw "The module '${analyzer.module
          .fullName}' has no top-level, public function named 'main'.";

    Future jitCompile(BonoboFunction function) async {
      await analyzer.functionAnalyzer.analyzeFunction(function);

      var errors =
          analyzer.errors.where((e) => e.severity == BonoboErrorSeverity.error);
      var warnings = analyzer.errors
          .where((e) => e.severity == BonoboErrorSeverity.warning);

      printErrors(errors);
      printErrors(warnings);

      if (errors.isNotEmpty || (argResults['strict'] && warnings.isNotEmpty)) {
        stderr.writeln('Compilation finished with errors.');
        exitCode = 1;
        return null;
      }

      Uint8List bytecode;
      bvm.loadFunction(function.fullName, bytecode);
    }

    // JIT-compile the main function we just found.
    await jitCompile(mainFunction);

    // Now, just run it.
    bvm.exec(mainFunction.fullName, []);
  }
}
