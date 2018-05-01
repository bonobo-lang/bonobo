part of bonobo.compiler.ssa;

class SSACompiler {
  Future compile(BonoboModule module) async {}

  Future<Procedure> compileFunction(
      BonoboFunction function, SSACompilerState state) {}
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
}
