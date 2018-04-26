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
    Iterable<BonoboError> errors, warnings;

    // Find the main function.
    var mainFunction = analyzer.module.mainFunction;

    if (mainFunction == null)
      throw "The module '${analyzer.module
          .fullName}' has no top-level, public function named 'main'.";

    Future lazyAnalyze(BonoboFunction function) async {
      await analyzer.functionAnalyzer.analyzeFunction(function);

      errors =
          analyzer.errors.where((e) => e.severity == BonoboErrorSeverity.error);
      warnings = analyzer.errors
          .where((e) => e.severity == BonoboErrorSeverity.warning);

      printErrors(errors);
      printErrors(warnings);
    }

    // Lazy analyze to find preliminary errors.
    await lazyAnalyze(mainFunction);

    if (errors.isNotEmpty || (argResults['strict'] && warnings.isNotEmpty)) {
      stderr.writeln('Compilation finished with errors.');
      exitCode = 1;
      return null;
    }

    // Create a new BVM.
    var bvm = new BVM();

    // And a compiler
    var bvmCompiler = new BVMCompiler();

    Future jitCompile(BonoboFunction function) async {
      await lazyAnalyze(function);

      if (errors.isNotEmpty || (argResults['strict'] && warnings.isNotEmpty)) {
        stderr.writeln('Compilation finished with errors.');
        exitCode = 1;
        return null;
      }

      var bytecode =
          await bvmCompiler.compileFunction(analyzer.module, function);
      bvm.loadFunction(function.fullName, bytecode);
    }

    // Listen for missing functions.
    bvm.onMissingFunction.listen((name) {
      var split = name.split('::');
      var module = analyzer.moduleSystem.core;

      for (int i = 0; i < split.length - 1; i++) {
        var child = module.children
            .firstWhere((c) => c.name == split[i], orElse: () => null);
        if (child != null)
          module = child;
        else
          throw 'Unknown function: $name';
      }

      var function = module.scope.allPublicVariables
          .firstWhere((v) => v.name == split.last && v.value is BonoboFunction,
              orElse: () => null)
          ?.value;

      if (function == null) throw 'Unknown function: $name';
      jitCompile(function);
    });

    // JIT-compile the main function we just found.
    var bytecode =
        await bvmCompiler.compileFunction(analyzer.module, mainFunction);
    print(bytecode.map((b) => '0x' + b.toRadixString(16)).toList());
    print(new String.fromCharCodes(bytecode));
    bvm.loadFunction(mainFunction.fullName, bytecode);

    // Now, just run it.
    //
    // Pass arguments, of course.
    bvm.exec(mainFunction.fullName, argResults.rest);
    bvm.startLoop();

    // TODO: Get last return value.
  }
}
