part of 'analysis.dart';

class BonoboAnalyzer {
  final List<BonoboError> errors = [];
  final BonoboModuleSystem moduleSystem;

  //final Parser parser;
  BonoboModule module;

  final Map<SourceLocation, BonoboObject> expressionCache = {};

  BonoboAnalyzer(this.moduleSystem);

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

        await resolveExpression(stmt.expression, function, scope);
      }

      if (stmt is ReturnStatementContext) {
        var value = await resolveExpression(stmt.expression, function, scope);
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
              value: await resolveExpression(
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

  Future<BonoboObject> resolveExpression(ExpressionContext ctx,
      BonoboFunction function, SymbolTable<BonoboObject> scope) async {
    //return expressionCache[ctx.span.start] ??=
    return await _resolveExpression(ctx, function, scope);
  }

  Future<BonoboObject> _resolveExpression(ExpressionContext ctx,
      BonoboFunction function, SymbolTable<BonoboObject> scope) async {
    final BonoboObject defaultObject =
        new BonoboObject(BonoboType.Root, ctx.span);

    // Literals
    if (ctx is NumberLiteralContext) {
      // TODO: Specific number suffixes, also explicit int or double
      return new BonoboObject(
          ctx.isByte ? BonoboType.Byte : BonoboType.Num, ctx.span);
    }

    if (ctx is StringLiteralContext) {
      return new BonoboObject(BonoboType.String$, ctx.span);
    }

    if (ctx is SimpleIdentifierContext) {
      var resolved = scope.resolve(ctx.name)?.value;

      if (resolved != null) {
        return resolved
          ..usages.add(new SymbolUsage(SymbolUsageType.declaration, ctx.span));
      }

      errors.add(new BonoboError(BonoboErrorSeverity.error,
          "The name '${ctx.name}' does not exist in this context.", ctx.span));
      return defaultObject;
    }

    if (ctx is NamespacedIdentifierContext) {
      var m = module;

      for (var part in ctx.namespaces) {
        var child = m.children
            .firstWhere((r) => r.name == part.name, orElse: () => null);

        if (child == null) {
          errors.add(new BonoboError(
              BonoboErrorSeverity.error,
              "The module '${m.name}' does not contain a submodule named '${part
                  .name}'.",
              part.span));
          return defaultObject;
        }

        m = child;
      }

      var symbol = m.scope.allVariables
          .firstWhere((v) => v.name == ctx.symbol.name, orElse: () => null);

      if (symbol == null) {
        errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            "The module '${m.name}' does not contain a value named '${ctx.symbol
                .name}'.",
            ctx.symbol.span));
      } else if (symbol.visibility < Visibility.public) {
        errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            "The symbol '${ctx.symbol
                .name}' is not public. Prepend a 'pub' modifier.",
            ctx.symbol.span));
      } else {
        return symbol.value;
      }
    }

    // Other expressions, lexicographical order
    if (ctx is AssignmentExpressionContext) {
      var leftCtx = ctx.left;

      if (leftCtx is! IdentifierContext) {
        // TODO: Do this for MemberExpression too
        errors.add(new BonoboError(BonoboErrorSeverity.error,
            'You cannot assign a value here.', leftCtx.span));
      } else if (leftCtx is SimpleIdentifierContext) {
        var symbol = scope.resolve(leftCtx.name);

        if (symbol == null) {
          errors.add(new BonoboError(
              BonoboErrorSeverity.error,
              "The name '${leftCtx.name}' does not exist in this context.",
              leftCtx.span));
        } else {
          BonoboObject value;

          if (ctx.operator.type == TokenType.equals) {
            value = await resolveExpression(ctx.right, function, scope);
          } else {
            // Make an artificial binary expression, and assign it as the value.
            var rootOperator = ctx.operator.span.text
                .substring(0, ctx.operator.span.length - 1);

            var binaryExpression = new BinaryExpressionContext(
              ctx.span,
              ctx.comments,
              leftCtx,
              ctx.right,
              BinaryOperator.fromTokenType(ctx.operator.type),
            );
            value = await resolveExpression(binaryExpression, function, scope);
          }

          try {
            return symbol.value = value;
          } on StateError catch (e) {
            errors.add(new BonoboError(
                BonoboErrorSeverity.error, e.message, leftCtx.span));
          }
        }
      }
    }

    if (ctx is BinaryExpressionContext) {
      var left = await resolveExpression(ctx.left, function, scope);
      var right = await resolveExpression(ctx.right, function, scope);
      var type = left.type.binaryOp(ctx.op, ctx.span, right.type, this);
      return new BonoboObject(type, ctx.span);
    }

    if (ctx is CallExpressionContext) {
      var target = await resolveExpression(ctx.target, function, scope);

      if (target is! BonoboFunction) {
        errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            "Cannot call an instance of '${target.type.name}' as a function.",
            ctx.span));
        return defaultObject;
      }

      var f = target as BonoboFunction;

      if (f.parameters.length != ctx.arguments.expressions.length) {
        var arguments = 'arguments', were = 'were';

        if (f.parameters.length == 1) arguments = 'argument';
        if (ctx.arguments.expressions.length == 1) were = 'was';

        errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            "'${f.name} expects ${f.parameters.length} $arguments, but ${ctx
                .arguments.expressions.length} $were provided.",
            ctx.span));
        return defaultObject;
      }

      bool parametersMatch = true;

      for (int i = 0; i < ctx.arguments.expressions.length; i++) {
        var p = f.parameters[i],
            arg = await resolveExpression(
                ctx.arguments.expressions[i], function, scope);

        if (arg.type != BonoboType.Root && !arg.type.isAssignableTo(p.type)) {
          errors.add(new BonoboError(
              BonoboErrorSeverity.error,
              "'${arg.type.name}' is not assignable to '${p.type.name}'.",
              ctx.arguments.expressions[i].span));
          parametersMatch = false;
        }

        // Attempt to infer the type of a parameter, if it has not been set.
        if (arg.type == BonoboType.Root) {
          var parameter = function.parameters
              .firstWhere((p) => p.name == arg.span.text, orElse: () => null);

          if (parameter?.type == BonoboType.Root) {
            parameter.type = p.type;
          }
        }
      }

      if (!parametersMatch) return defaultObject;

      return new BonoboObject(f.returnType, ctx.span);
    }

    if (ctx is MemberExpressionContext) {
      var targetExpression = ctx.target;

      // If the target expression is neither an ID nor a member expression,
      // then we should attempt to access a field.
      if (targetExpression is! IdentifierContext) {
        // TODO: Access fields
        // For now, though, Bonobo types do not have fields.
        // https://github.com/bonobo-lang/bonobo/issues/29
        errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            'Bonobo types currently do not have fields',
            targetExpression.span));
        return defaultObject;
      }

      // TODO: What if resolving the member expression produces a module?
      // Probably use a loop to reduce this

      // In the case of a MemberExpression,
      // we can either be getting an exported symbol from a child module,
      // or one from a symbol within this scope.
      // A symbol within this scope will take precedence, so let's look for that first.
      var targetId = targetExpression as IdentifierContext;
      var referencedObject = scope.resolve(targetId.name)?.value;

      if (referencedObject != null) return referencedObject;

      // If there is no value with the given name within this scope,
      // then we should look for a public symbol.
      //
      // This symbol will come either from the local submodules, or the
      // globally-included third-party modules.
      var modules = new List<BonoboModule>.from(this.module.children);
      modules.addAll(moduleSystem.rootModule.parent.children);

      // Now that we have the names of the libraries the symbol could potentially
      // be coming from, let's find the library
      var module = modules.firstWhere((m) => m.name == targetId.name,
          orElse: () => null);

      if (module == null) {
        errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            "There is no library or identifier named '${targetId
                .name}' in this context.",
            targetExpression.span));
        return defaultObject;
      }

      // TODO: Add aliased imports
      // Now that we've found the module in question,
      // we need to find the symbol.
      //
      // According to Bonobo's module system, this must be a public symbol.
      var allSymbols = module.scope.allPublicVariables;
      var symbolName = ctx.identifier.name;

      var correspondingSymbol = allSymbols
          .firstWhere((v) => v.name == symbolName, orElse: () => null);

      if (correspondingSymbol == null) {
        errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            "The library '${module
                .name}' has no public symbol named '$symbolName'.",
            ctx.identifier.span));
        return defaultObject;
      }

      return correspondingSymbol.value;
    }

    if (ctx is TupleExpressionContext) {
      var expressions = await Future.wait(
          ctx.expressions.map((e) => resolveExpression(e, function, scope)));
      var type = new BonoboTupleType(expressions.map((e) => e.type).toList());
      return new BonoboObject(type, ctx.span);
    }

    errors.add(new BonoboError(
        BonoboErrorSeverity.error,
        "Cannot resolve type of expression '${ctx.span.text}' (${ctx
            .runtimeType}).",
        ctx.span));
    return defaultObject;
  }
}
