part of bonobo.src.analysis;

class StatementAnalyzer {
  final BonoboAnalyzer analyzer;

  StatementAnalyzer(this.analyzer);

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
        if (stmt.expression is! CallExpressionContext
            // TODO: Assignments?
            //&& stmt.expression is! AssignmentExpressionContext
            ) {
          analyzer.errors.add(new BonoboError(
              BonoboErrorSeverity.warning,
              'Dead code - expression is neither a call, nor an assignment.',
              stmt.expression.span));
        }

        await analyzer.expressionAnalyzer
            .resolve(stmt.expression, function, scope);
      }

      if (stmt is ReturnStatementContext) {
        var value = await analyzer.expressionAnalyzer
            .resolve(stmt.expression, function, scope);
        deadCode = true;

        if (function.returnType != null) {
          if (value.type.isAssignableTo(function.returnType))
            flow.returnType = value.type;
          else {
            analyzer.errors.add(new BonoboError(
                BonoboErrorSeverity.error,
                "'${function.name}' is declared to return a value of type "
                "'${function.returnType}', but it "
                "returns a value of type '${value.type}'.",
                stmt.expression.span));
            flow.returnType = BonoboType.Root;
          }
        } else {
          flow.returnType = value.type;
        }
      }

      if (stmt is VariableDeclarationStatementContext) {
        var childScope = stmt.scope = scope.createChild();

        for (var decl in stmt.declarations) {
          try {
            childScope.create(
              decl.name.name,
              value: await analyzer.expressionAnalyzer
                  .resolve(decl.expression, function, childScope),
              constant: stmt.isImmutable,
            );
          } on StateError catch (e) {
            analyzer.errors.add(new BonoboError(
              BonoboErrorSeverity.error,
              e.message,
              decl.name.span,
            ));
          }
        }

        var childFlow = stmt.flow =
            await analyzeBlock(stmt.context, function, childScope, deadCode);
        flow.children.add(childFlow);
      }
    }

    if (deadCodeSpan != null) {
      analyzer.errors.add(new BonoboError(
          BonoboErrorSeverity.warning, 'Dead code.', deadCodeSpan));
    }

    return flow;
  }
}
