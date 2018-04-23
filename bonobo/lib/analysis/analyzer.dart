part of 'analysis.dart';

class BonoboAnalyzer {
  final List<BonoboError> errors = [];
  final BonoboModuleSystem moduleSystem;
  ExpressionAnalyzer expressionAnalyzer;

  //final Parser parser;
  BonoboModule module;

  final Map<SourceLocation, BonoboObject> expressionCache = {};

  BonoboAnalyzer(this.moduleSystem) {
    expressionAnalyzer = new ExpressionAnalyzer(this);
  }

  // TODO: Find unused symbols
  Future analyze(
      CompilationUnitContext compilationUnit, Uri sourceUrl, Parser parser,
      [BonoboModule m]) async {
    var functions = <BonoboFunction>[];

    // Figure out which module we're even working in...
    module = m ??
        await moduleSystem.findModuleForFile(
            sourceUrl, moduleSystem.rootModule);
    //module = moduleSystem.rootModule;

    if (module.compilationUnits[sourceUrl] != null) {
      return;
    }

    module.compilationUnits[sourceUrl] = compilationUnit;
    errors.addAll(parser.errors);

    // Get the names of all types that are not typedefs.
    // TODO: Custom classes, etc.

    // Next, find the names of all typedefs.
    for (var typedef in compilationUnit.typedefs) {
      // For each typedef, create an empty one in the module's
      // type dictionary.
      //
      // This will be populated, but this allows for forward references, etc.
      var existing = module.types[typedef.name.name];

      if (existing != null) {
        errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            "Typedef '${typedef.name
                .name}' conflicts with the name of an existing type.",
            typedef.span));

        if (existing.span != null) {
          errors.add(new BonoboError(
              BonoboErrorSeverity.warning,
              "A typedef declared elsewhere conflicts with this type.",
              existing.span));
        }
      } else if (existing == null) {
        module.types[typedef.name.name] =
            new BonoboTypedef(typedef.name.name, typedef.span);
      }
    }

    // Populate any typedefs.
    for (var typedef in compilationUnit.typedefs) {
      var type = module.types[typedef.name.name];
      if (type is BonoboTypedef) {
        type.type = await resolveType(typedef.type);
      }
    }

    // Get the names of all functions
    for (var ctx in compilationUnit.functions) {
      try {
        var function = new BonoboFunction(
            ctx.name.name, module.scope.createChild(), ctx, module);
        functions.add(function);
        function.usages
            .add(new SymbolUsage(SymbolUsageType.declaration, ctx.name.span));

        var symbol =
            module.scope.create(ctx.name.name, value: function, constant: true);

        if (ctx.isHidden) {
          symbol.visibility = Visibility.private;
        } else {
          symbol.visibility = Visibility.public;
        }

        if (ctx.signature.parameterList != null) {
          // Create parameters, without types
          for (var p in ctx.signature.parameterList.parameters) {
            function.parameters
                .add(new BonoboFunctionParameter(p.name.name, p.span));
          }

          // Add the names of every parameter
          for (var p in function.parameters) {
            function.scope.create(p.name);
          }
        }
      } on StateError catch (e) {
        errors.add(
            new BonoboError(BonoboErrorSeverity.error, e.message, ctx.span));
      }
    }

    // Collect signature information.
    for (var ctx in functions) {
      await populateFunctionSignature(ctx);
    }

    // Now, analyze them fully.
    for (var ctx in functions) {
      await analyzeFunction(ctx);
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
            .add(new SymbolUsage(SymbolUsageType.declaration, decl.name.span));

      if (decl.type != null) {
        p.type.usages
            .add(new SymbolUsage(SymbolUsageType.read, decl.type.span));
      }
    }

    if (function.declaration.signature.returnType != null) {
      function.returnType =
          await resolveType(function.declaration.signature.returnType);
      function.returnType.usages.add(new SymbolUsage(SymbolUsageType.read,
          function.declaration.signature.returnType.span));
    } else
      function.returnType = BonoboType.Root;
  }

  Future analyzeFunction(BonoboFunction function) async {
    function.body = await analyzeControlFlow(function);

    if (function.declaration.signature.returnType == null) {
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

        await expressionAnalyzer.resolve(stmt.expression, function, scope);
      }

      if (stmt is ReturnStatementContext) {
        var value = await expressionAnalyzer.resolve(stmt.expression, function, scope);
        deadCode = true;

        if (function.returnType != null) {
          if (value.type.isAssignableTo(function.returnType))
            flow.returnType = value.type;
          else {
            errors.add(new BonoboError(
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
              value: await expressionAnalyzer.resolve(
                  decl.initializer, function, childScope),
              constant: decl.isImmutable,
            );
          } on StateError catch (e) {
            errors.add(new BonoboError(
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
      errors.add(new BonoboError(
          BonoboErrorSeverity.warning, 'Dead code.', deadCodeSpan));
    }

    return flow;
  }

  Future<BonoboType> resolveType(TypeContext ctx) async {
    if (ctx == null)
      return BonoboType.Root;
    else if (ctx is SimpleIdentifierTypeContext) {
      BonoboModule m = module;

      do {
        var existing = m.types[ctx.identifier.name];

        if (existing != null) return existing;
        m = m.parent;
      } while (m != null);

      errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Unknown type '${ctx.identifier.name}'.", ctx.span));

      return BonoboType.Root;
    } else if (ctx is StructTypeContext) {
      var fields = <String, BonoboType>{};

      for (var field in ctx.fields) {
        fields[field.name.name] = await resolveType(field.type);
      }

      return new BonoboStructType(fields);
    } else if (ctx is EnumTypeContext) {
      var values = ctx.values
          .map((v) => new BonoboEnumValue(v.name.name, v.index?.intValue))
          .toList();
      return new BonoboEnumType(values);
    } else if (ctx is TupleTypeContext) {
      var types = await Future.wait(ctx.items.map(resolveType));
      return new BonoboTupleType(types);
    } else if (ctx is FunctionTypeContext) {
      var parameters = await Future.wait(ctx.parameters.map(resolveType));
      var returnType = await resolveType(ctx.returnType);
      return new BonoboFunctionType(parameters, returnType);
    } else {
      errors.add(new BonoboError(BonoboErrorSeverity.warning,
          'Unsupported type: ${ctx.runtimeType}', ctx.span));
      return BonoboType.Root;
    }
  }
}
