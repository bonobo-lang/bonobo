part of bonobo.compiler.ssa;

class SSACompiler {
  final List<BonoboError> errors = [];
  final LinearMemory<Procedure> _addresses = new LinearMemory(0);
  final Map<BonoboFunction, Procedure> _procedures = {};

  Future compile(BonoboModule module) async {
    var program = new Program();
    var main = module.mainFunction;
    var state = new SSACompilerState(program, main, module, null);
    await compileFunction(main, state);
  }

  Future<Procedure> compileFunction(
      BonoboFunction function, SSACompilerState state) async {
    if (_procedures.containsKey(function)) return _procedures[function];

    var proc = _procedures[function] = new Procedure(function.fullName);

    var block = _addresses.allocate(proc.size);
    if (block == null) {
      _addresses.grow(_addresses.size + proc.size);
      block = _addresses.allocate(proc.size);
    }

    proc.location = block;
    return proc;
  }
}

class SSACompilerState {
  final Program program;
  final BonoboFunction function;
  final BonoboModule module;
  final DominanceFrontier dominanceFrontier;

  SSACompilerState(
      this.program, this.function, this.module, this.dominanceFrontier);

  BonoboAnalyzer get analyzer => module.analyzer;

  BonoboModuleSystem get moduleSystem => module.moduleSystem;

  SSACompilerState copyWith(
      {Program program,
      BonoboFunction function,
      BonoboModule module,
      DominanceFrontier dominanceFrontier}) {
    return new SSACompilerState(
        program ?? this.program,
        function ?? this.function,
        module ?? this.module,
        dominanceFrontier ?? this.dominanceFrontier);
  }
}
