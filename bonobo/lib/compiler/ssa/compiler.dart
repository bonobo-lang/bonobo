part of bonobo.compiler.ssa;

const SSACompiler ssaCompiler = const SSACompiler._();

class SSACompiler {
  static const int pointerSize = 32;

  const SSACompiler._();

  static List<int> pointer32(int pointer) {
    return [
      // Encode 32-bit pointer
      (pointer >> (8 * 0)) & 0xff,
      (pointer >> (8 * 1)) & 0xff,
      (pointer >> (8 * 2)) & 0xff,
      (pointer >> (8 * 3)) & 0xff,
    ];
  }

  Future<Tuple2<Program, SSACompilerState>> compile(
      BonoboModule module, List<BonoboError> errors,
      [SSACompilerState state]) async {
    var program = new Program();
    var main = module.mainFunction;
    state ??= new SSACompilerState(
        program, main, module, null, null, null, errors, main.scope, main.body);
    state = await compileFunction(main, state).then((t) => t.item2);
    return new Tuple2(program, state);
  }

  Future<Tuple2<Procedure, SSACompilerState>> compileFunction(
      BonoboFunction function, SSACompilerState state) async {
    if (state.procedures.containsKey(function))
      return new Tuple2(state.procedures[function], state);

    Procedure proc;

    if (function is BonoboNativeFunction) {
      state = await function.compileSSA(this, state);
      proc = state.procedure;
    } else {
      proc = state.procedures[function] = new Procedure(function.fullName);
      var block = new BasicBlock('entry');
      proc.blocks.add(block);
      state = await compileControlFlow(
          function.body,
          state.copyWith(
            function: function,
            dominanceFrontier: new DominanceFrontier(),
            procedure: proc,
            block: block,
            controlFlow: function.body,
          ));
    }

    if (proc.size > 0) {
      var block = state.addresses.allocate(proc.size);
      if (block == null) {
        state.addresses.grow(state.addresses.size + proc.size);
        block = state.addresses.allocate(proc.size);
      }

      proc.location = block;
      state.program.procedures.add(proc);
    }

    return new Tuple2(proc, state);
  }

  SSACompilerState emitInstruction(
      SSACompilerState state, Instruction instruction) {
    state.block.entry ??= instruction;
    state.dominanceFrontier?.next = instruction;
    return state.copyWith(dominanceFrontier: instruction.dominanceFrontier);
  }

  Future<SSACompilerState> compileControlFlow(
      ControlFlow controlFlow, SSACompilerState state) async {
    state = state.copyWith(controlFlow: controlFlow);

    for (var statement in controlFlow.statements) {
      if (statement is ExpressionStatementContext)
        return state = await compileExpression(statement.expression, state)
            .then((t) => t.item2);
      else if (statement is ReturnStatementContext) {
        state = await compileExpression(statement.expression, state)
            .then((t) => t.item2);
        state = emitInstruction(
            state,
            new BasicInstruction(BVMOpcode.RET, [], statement.span,
                state.dominanceFrontier.createChild()));
        return state;
      }

      throw 'Cannot compile ${statement.runtimeType}\n${statement.span
          ?.highlight() ?? ''}';
    }

    return state;
  }

  Future<Tuple2<RegisterValue, SSACompilerState>> compileExpression(
      ExpressionContext ctx, SSACompilerState state) async {
    if (ctx is StringLiteralContext) {
      var constant = state.constantCache.putIfAbsent(ctx.value, () {
        // Make an entry in the .data section
        state.dataSection.grow(state.dataSection.size + ctx.value.length + 1);
        var value = new RegisterValue(
            RegisterValueType.string, ctx.value.length + 1, ctx.span);
        return state.dataSection.allocate(value.size, value);
      });

      // We know where the constant is, in reference to the data section.
      // Nice.
      //
      // But, how on Earth can we access this value?
      // Well, if data is read-only, and functions are execute-only, then
      // this is no problem.
      //
      // Just pass the offset, and BVM will interpret that.
      //
      // Put the string's offset in EAX.
      state = emitInstruction(
          state,
          new BasicInstruction(
              BVMOpcode.MOV,
              [
                BVMRegister.EAX,
                0, // Offset: 0
                4, // The size of the data to put into the register.
              ]..addAll(pointer32(constant.offset)),
              ctx.span,
              state.dominanceFrontier.createChild()));

      var value = new RegisterValue(RegisterValueType.string, 4, ctx.span);
      state.program.registers.accumulator.set(value, (spill) {
        // TODO: Spill
      });

      return new Tuple2(value, state);
    }

    if (ctx is CallExpressionContext) {
      for (int i = ctx.arguments.expressions.length - 1; i >= 0; i--) {
        var arg = ctx.arguments.expressions[i];
        var result = await compileExpression(arg, state);
        var value = result.item1;
        state = result.item2;
        var reg = state.program.registers.firstAvailable(value.size);

        reg.set(value, (spill) {
          // TODO: Handle spilling by allocating memory and moving
        });

        var tgt = await state.analyzer.expressionAnalyzer
            .resolve(ctx.target, state.function, state.scope);

        if (tgt is! BonoboFunction) {
          throw '$tgt is not a function.\n${tgt.span?.highlight() ?? ''}';
        }

        var target = tgt as BonoboFunction;
        var tuple = await compileFunction(target, state);
        var pointer = tuple.item1.location.offset;
        state = emitInstruction(
            tuple.item2,
            new BasicInstruction(BVMOpcode.CALL, pointer32(pointer), ctx.span,
                state.dominanceFrontier.createChild()));

        // The return value will be in EAX, if anything at all.
        value = new RegisterValue(
            target.returnType.bvmType, target.returnType.size, target.span);
        return new Tuple2(value, state);
      }
    }

    var object = await state.analyzer.expressionAnalyzer
        .resolve(ctx, state.function, state.scope);
    return await compileObject(object, state);
  }

  Future<Tuple2<RegisterValue, SSACompilerState>> compileObject(
      BonoboObject object, SSACompilerState state) async {
    throw 'Cannot compile ${object.type}\n${object.span?.highlight() ?? ''}';
  }
}

class SSACompilerState {
  final List<BonoboError> errors;
  final LinearMemory<Procedure> addresses = new LinearMemory(0);
  final LinearMemory<RegisterValue> dataSection = new LinearMemory(0);
  final Map<dynamic, MemoryBlock<RegisterValue>> constantCache = {};
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
