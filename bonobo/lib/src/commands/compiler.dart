part of bonobo.src.commands;

final c.Expression String_new = new c.Expression('String_new');

c.Code gdbLineInfo(SourceSpan span) {
  return new c.Code(
      '#line ${span.start.line + 1} "${span.sourceUrl.toFilePath()}"');
}

class BonoboCCompiler {
  final List<BonoboError> errors = [];
  final c.CompilationUnit output = new c.CompilationUnit();
  final BonoboAnalyzer analyzer;

  BonoboCCompiler(this.analyzer) {
    errors.addAll(analyzer.errors);
  }

  Future compile() async {
    var signatures = <c.FunctionSignature>[];
    BonoboFunction mainFunction;

    for (var symbol in analyzer.rootScope.allPublicVariables) {
      if (symbol.value is BonoboFunction) {
        var f = symbol.value as BonoboFunction;
        if (f.name == 'main') mainFunction = f;
        await compileFunction(f, signatures);
      }
    }

    if (mainFunction == null) {
      errors.add(new BonoboError(
        BonoboErrorSeverity.error,
        "A 'main' function is required.",
        analyzer.parser.scanner.emptySpan,
      ));
    } else {
      // Insert forward declarations of all functions
      output.body.insertAll(0, signatures);

      // Insert all includes
      output.body.insertAll(0, [
        // Necessary standard imports.
        new c.Include.system('stdint.h'),

        // Import the Bonobo runtime.
        new c.Include.system('bonobo.h'),
      ]);

      // Create a simple int main() that just calls _main()
      output.body
          .add(new c.CFunction(new c.FunctionSignature(c.CType.int, 'main'))
            ..body.addAll([
              new c.Expression('_main').invoke([]),
              new c.Expression.value(0).asReturn(),
            ]));
    }
  }

  Future compileFunction(
      BonoboFunction ctx, List<c.FunctionSignature> signatures) async {
    var returnType = await compileType(ctx.returnType);

    if (returnType == null) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Cannot resolve type '${ctx.returnType.name}' to a C type.",
          ctx.declaration.signature.returnType?.span ??
              ctx.declaration.signature.span));
      return;
    }

    var signature = new c.FunctionSignature(
        returnType, ctx.name == 'main' ? '_main' : ctx.name);
    signatures.add(signature);
    var function = new c.CFunction(signature);
    output.body.addAll([
      gdbLineInfo(ctx.span),
      function,
    ]);

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

    function.body.addAll(await compileControlFlow(ctx.body, ctx, ctx.scope));
  }

  Future<List<c.Code>> compileControlFlow(
      ControlFlow ctx, BonoboFunction function, SymbolTable scope) async {
    var out = [];

    for (int i = 0; i < ctx.statements.length; i++) {
      var stmt = ctx.statements[i];

      if (stmt is ReturnStatementContext) {
        var expression = await compileExpression(stmt.expression, out, scope);
        out.addAll([gdbLineInfo(stmt.span), expression.asReturn()]);
      }
    }

    return out;
  }

  Future<c.CType> compileType(BonoboType type) async {
    // TODO: Array types? Generics?
    return type.ctype ?? analyzer.types[type.name];
  }

  Future<c.Expression> compileExpression(
      ExpressionContext ctx, List<c.Code> body, SymbolTable scope) async {
    // Literals
    if (ctx is IdentifierContext) {
      return new c.Expression(ctx.name);
    }

    if (ctx is NumberLiteralContext) {
      // TODO: Different types of numbers?
      return new c.Expression(ctx.span.text);
    }

    if (ctx is StringLiteralContext) {
      var value = removeQuotesFromString(ctx.span.text)
          .replaceAll("\\'", "'")
          .replaceAll('"', '\\"');
      return new c.Expression('"$value"');
      //var data = new c.Expression.value(ctx.value);
      //return String_new.invoke([data]);
    }

    if (ctx is CallExpressionContext) {
      var target = await compileExpression(ctx.target, body, scope);
      var arguments = await Future.wait(ctx.arguments.expressions
          .map((e) => compileExpression(e, body, scope)));
      return target.invoke(arguments);
    }

    if (ctx is PrintExpressionContext) {
      var name = scope.uniqueName('printValue');
      var value = await analyzer.resolveExpression(ctx.expression, scope);
      var cType = await compileType(value.type);
      var cExpression = await compileExpression(ctx.expression, body, scope);
      var id = new c.Expression(name);
      body.addAll([
        new c.Field(cType, name, cExpression),
        new c.Expression('${value.type.name}_print').invoke([id]),
      ]);

      return id;
    }

    throw new ArgumentError(
        'Cannot compile ${ctx.runtimeType} to C yet!!!\n${ctx.span.highlight()}');
  }
}
