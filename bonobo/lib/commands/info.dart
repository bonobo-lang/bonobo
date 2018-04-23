part of bonobo.src.commands;

class InfoCommand extends Command {
  String get name => 'info';

  String get description => 'Prints information about the current module.';

  bool initialized = false;
  BonoboAnalyzer analyzer;

  @override
  run() async {
    analyzer = await analyze(this);

    var errors =
        analyzer.errors.where((e) => e.severity == BonoboErrorSeverity.error);
    var warnings =
        analyzer.errors.where((e) => e.severity == BonoboErrorSeverity.warning);

    printErrors(errors);
    printErrors(warnings);

    analyzer.moduleSystem.dumpTree(analyzer.module);
  }
}
