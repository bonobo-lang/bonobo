part of bonobo.src.analysis;

class BonoboAnalyzer {
  final List<BonoboError> errors = [];
  final Map<String, BonoboType> types = {};
  final CompilationUnitContext compilationUnit;
  final Uri sourceUrl;
  AnalysisContext analysisContext;
  SymbolTable<BonoboObject> rootScope;
  SymbolTable<BonoboObject> currentScope;

  BonoboAnalyzer(this.compilationUnit, this.sourceUrl, Parser parser) {
    errors.addAll(parser.errors);
  }

  // TODO: Find unused symbols
  Future analyze() async {
    analysisContext = new AnalysisContext(this);
    currentScope = rootScope = await createRootScope(analysisContext);
    types.addAll(await createGlobalTypes(analysisContext));

    var functions = <BonoboFunction>[];

    // Get the names of all functions
    for (var ctx in compilationUnit.functions) {
      try {
        var function =
            new BonoboFunction(ctx.name.name, currentScope.createChild(), ctx);
        functions.add(function);
        function.usages
            .add(new SymbolUsage(SymbolUsageType.declaration, ctx.name.span));
        currentScope.create(ctx.name.name, value: function, constant: true);

        // Create parameters, without types
        for (var p in ctx.signature.parameterList.parameters) {
          function.parameters
              .add(new BonoboFunctionParameter(p.name.name, p.span));
        }

        // Add the names of every parameter
        for (var p in function.parameters) {
          function.scope.create(p.name);
        }
      } on StateError catch (e) {
        errors.add(
            new BonoboError(BonoboErrorSeverity.error, e.message, ctx.span));
      }
    }

    // Now, analyze them fully.
    for (var ctx in functions) {
      await populateFunctionSignature(ctx);
    }

    for (var ctx in functions) {
      await analyzeFunction(ctx);

      if (ctx.returnType.isAssignableTo(BonoboType.Function$)) {
        errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            'Higher-order functions are not (yet) supported in Bonobo.',
            ctx.declaration.name.span));
        ctx.returnType = BonoboType.Root;
      }
    }
  }

  Future populateFunctionSignature(BonoboFunction function) async {
    for (int i = 0; i < function.parameters.length; i++) {
      var p = function.parameters[i];
      var decl = function.declaration.signature.parameterList.parameters[i];
      p.type = await resolveType(decl.type);
      function.scope.assign(p.name, new BonoboObject(p.type, p.span))
        ..value
            .usages
            .add(new SymbolUsage(SymbolUsageType.declaration, decl.name.span))
        ..lock();

      if (decl.type != null) {
        p.type.usages
            .add(new SymbolUsage(SymbolUsageType.read, decl.type.span));
      }
    }
  }

  Future analyzeFunction(BonoboFunction function) async {
    bool shouldInfer = function.declaration.signature.returnType == null;

    if (!shouldInfer) {
      function.returnType =
          await resolveType(function.declaration.signature.returnType);
      function.returnType.usages.add(new SymbolUsage(SymbolUsageType.read,
          function.declaration.signature.returnType.span));
    }

    function.body = await analyzeControlFlow(function);

    if (shouldInfer) {
      // Attempt to infer the return type, if none is specified
      function.returnType = function.body.returnType ?? BonoboType.Root;
    }
  }

  Future<ControlFlow> analyzeControlFlow(BonoboFunction function) async {
    return await analyzeBlock(
        function.declaration.body.body, function, function.scope, false);
  }

  // TODO: Infer the type of parameters from the functions they are called against

  Future<ControlFlow> analyzeBlock(
      List<StatementContext> statements,
      BonoboFunction function,
      SymbolTable<BonoboObject> scope,
      bool deadCode) async {
    var flow = new ControlFlow();
    FileSpan deadCodeSpan;
    bool codeWasInitiallyAlive = !deadCode;

    for (var stmt in statements) {
      if (!codeWasInitiallyAlive) {
        continue;
      } else if (deadCode) {
        deadCodeSpan =
            deadCodeSpan == null ? stmt.span : deadCodeSpan.expand(stmt.span);
        continue;
      }

      flow.statements.add(stmt);

      if (stmt is ExpressionStatementContext) {
        if (stmt.expression is! CallExpressionContext &&
            stmt.expression is! AssignmentExpressionContext) {
          errors.add(new BonoboError(
              BonoboErrorSeverity.warning,
              'Dead code - expression is neither a call, nor an assignment.',
              stmt.expression.span));
        }
      }

      if (stmt is ReturnStatementContext) {
        var value = await resolveExpression(stmt.expression, scope);
        deadCode = true;

        if (function.returnType != null) {
          if (value.type.isAssignableTo(function.returnType))
            flow.returnType = value.type;
          else {
            errors.add(new BonoboError(
                BonoboErrorSeverity.error,
                "'${function.name}' is declared to return a value of type "
                "'${function.returnType.name}', but it "
                "returns a value of type '${value.type.name}'.",
                stmt.expression.span));
            flow.returnType = BonoboType.Root;
          }
        } else {
          flow.returnType = value.type;
        }
      }
    }

    if (deadCodeSpan != null) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.warning, 'Dead code.', deadCodeSpan));
    }

    return flow;
  }

  Future<BonoboType> resolveType(TypeContext ctx) async {
    if (ctx == null)
      return BonoboType.Root;
    else if (ctx is IdentifierTypeContext) {
      var existing = types[ctx.identifier.name];

      if (existing == null) {
        errors.add(new BonoboError(BonoboErrorSeverity.error,
            "Unknown type '${ctx.identifier.name}'.", ctx.span));

        return BonoboType.Root;
      }

      return existing;
    } else {
      throw new ArgumentError();
    }
  }

  Future<BonoboObject> resolveExpression(
      ExpressionContext ctx, SymbolTable<BonoboObject> scope) async {
    final BonoboObject defaultObject =
        new BonoboObject(BonoboType.Root, ctx.span);

    if (ctx is ParenthesizedExpressionContext) {
      return await resolveExpression(ctx.expression, scope);
    }

    if (ctx is NumberLiteralContext) {
      return new BonoboObject(BonoboType.Num, ctx.span);
    }

    if (ctx is StringLiteralContext) {
      return new BonoboObject(BonoboType.String$, ctx.span);
    }

    if (ctx is IdentifierContext) {
      var resolved = scope.resolve(ctx.name)?.value;

      if (resolved != null) {
        return resolved
          ..usages.add(new SymbolUsage(SymbolUsageType.declaration, ctx.span));
      }

      errors.add(new BonoboError(BonoboErrorSeverity.error,
          "The name '${ctx.name}' does not exist in this context.", ctx.span));
      return defaultObject;
    }

    if (ctx is PrintExpressionContext)
      return await resolveExpression(ctx.expression, scope);

    errors.add(new BonoboError(BonoboErrorSeverity.error,
        "Cannot resolve type of expression '${ctx.span.text}'.", ctx.span));
    return defaultObject;
  }
}
