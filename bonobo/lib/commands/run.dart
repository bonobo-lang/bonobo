part of bonobo.src.commands;

class RunCommand extends Command {
  String get name => 'run';

  String get description => 'JIT-compiles and runs a Bonobo module.';

  @override
  run() async {
    var analyzer = await analyze(this, eager: false);

    // Create a new BVM.
    var bvm = new BVM();

    // Analyze main function.
  }
}
