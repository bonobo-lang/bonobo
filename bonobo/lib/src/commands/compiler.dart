part of bonobo.src.commands;

class BonoboCCompiler {
  final List<BonoboError> errors = [];
  final c.CompilationUnit output = new c.CompilationUnit();
  final BonoboAnalyzer analyzer;

  BonoboCCompiler(this.analyzer) {
    errors.addAll(analyzer.errors);
  }

  Future compile() async {
    // Import the Bonobo runtime, first and foremost.
    output.body.add(new c.Include.system('bonobo.h'));

    for (var symbol in analyzer.rootScope.allPublicVariables) {
      if (symbol.value is BonoboFunction) {
        await compileFunction(symbol.value);
      }
    }
  }

  Future compileFunction(BonoboFunction ctx) async {
    var returnType = await compileType(ctx.returnType);

    if (returnType == null) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Cannot resolve type '${ctx.returnType.name}' to a C type.",
          ctx.declaration.signature.returnType?.span ??
              ctx.declaration.signature.span));
      return;
    }

    var signature = new c.FunctionSignature(returnType, ctx.name);
    var function = new c.CFunction(signature);
    output.body.add(function);

    for (var p in ctx.parameters) {
      var type = await compileType(p.type);

      if (type == null) {
        errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            "Cannot resolve type of parameter '${p.name}' to a C type.",
            p.span));
        return;
      }

      function.signature.parameters.add(new c.Parameter(type, p.name));
    }

    await compileControlFlow(ctx.body, ctx);
  }

  Future compileControlFlow(ControlFlow ctx, BonoboFunction function) async {}

  Future<c.CType> compileType(BonoboType type) async {
    // TODO: Array types? Generics?
    return type.ctype ?? analyzer.types[type.name];
  }
}
