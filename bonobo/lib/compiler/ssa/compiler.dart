part of bonobo.compiler.ssa;

const SSACompiler ssaCompiler = const SSACompiler._();

class SSACompiler {
  const SSACompiler._();

  Future<Tuple2<Program, SSACompilerState>> compile(
      BonoboModule module, List<BonoboError> errors) async {
    var program = new Program();
    var main = module.mainFunction;
    var state = new SSACompilerState(
        program, main, module, null, null, null, errors, main.scope, main.body);
    await compileFunction(main, state);
    return new Tuple2(program, state);
  }

  Future<Procedure> compileFunction(
      BonoboFunction function, SSACompilerState state) async {
    if (state.procedures.containsKey(function))
      return state.procedures[function];

    var proc = state.procedures[function] = new Procedure(function.fullName);
    var block = new BasicBlock('entry');
    proc.blocks.add(block);

    await compileControlFlow(
        function.body,
        state.copyWith(
          function: function,
          dominanceFrontier: new DominanceFrontier(),
          procedure: proc,
          block: block,
          controlFlow: function.body,
        ));

    if (proc.size > 0) {
      var block = state.addresses.allocate(proc.size);
      if (block == null) {
        state.addresses.grow(state.addresses.size + proc.size);
        block = state.addresses.allocate(proc.size);
      }

      proc.location = block;
    }

    return proc;
  }

  Future compileControlFlow(
      ControlFlow controlFlow, SSACompilerState state) async {
    state = state.copyWith(controlFlow: controlFlow);

    for (var statement in controlFlow.statements) {
      if (statement is ExpressionStatementContext)
        return await compileExpression(statement.expression, state);
    }
  }

  Future<RegisterValue> compileExpression(
      ExpressionContext ctx, SSACompilerState state) async {
    var object = await state.analyzer.expressionAnalyzer
        .resolve(ctx, state.function, state.scope);
    return await compileObject(object, state);
  }

  Future<RegisterValue> compileObject(
      BonoboObject object, SSACompilerState state) async {
    throw 'Cannot compile ${object.type}';
  }
}

class SSACompilerState {
  final List<BonoboError> errors;
  final LinearMemory<Procedure> addresses = new LinearMemory(0);
  final LinearMemory<RegisterValue> constants = new LinearMemory(0);
  final Map<BonoboFunction, Procedure> procedures = {};
  final Program program;
  final BonoboFunction function;
  final BonoboModule module;
  final DominanceFrontier dominanceFrontier;
  final Procedure procedure;
  final Block block;
  final SymbolTable<BonoboObject> scope;
  final ControlFlow controlFlow;

  SSACompilerState(
      this.program,
      this.function,
      this.module,
      this.dominanceFrontier,
      this.procedure,
      this.block,
      this.errors,
      this.scope,
      this.controlFlow);

  BonoboAnalyzer get analyzer => module.analyzer;

  BonoboModuleSystem get moduleSystem => module.moduleSystem;

  SSACompilerState copyWith(
      {Program program,
      BonoboFunction function,
      BonoboModule module,
      DominanceFrontier dominanceFrontier,
      Procedure procedure,
      Block block,
      SymbolTable<BonoboObject> scope,
      ControlFlow controlFlow}) {
    return new SSACompilerState(
        program ?? this.program,
        function ?? this.function,
        module ?? this.module,
        dominanceFrontier ?? this.dominanceFrontier,
        procedure ?? this.procedure,
        block ?? this.block,
        this.errors,
        scope ?? this.scope,
        controlFlow ?? this.controlFlow);
  }
}
