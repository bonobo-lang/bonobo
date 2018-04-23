part of bonobo.src.analysis;

class ExpressionAnalyzer {
  final BonoboAnalyzer analyzer;

  ExpressionAnalyzer(this.analyzer);

  Future<BonoboObject> resolve(ExpressionContext ctx, BonoboFunction function,
      SymbolTable<BonoboObject> scope) async {
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
      return await resolveSimpleIdentifier(ctx, scope, defaultObject);
    }

    if (ctx is NamespacedIdentifierContext) {
      return resolveNamespacedIdentifierContext(ctx, defaultObject);
    }

    // Other expressions, lexicographical order
    if (ctx is AssignmentExpressionContext) {
      return await resolveAssignmentExpression(
          ctx, function, scope, defaultObject);
    }

    if (ctx is BinaryExpressionContext) {
      var left = await resolve(ctx.left, function, scope);
      var right = await resolve(ctx.right, function, scope);
      var type = left.type.binaryOp(ctx.op, ctx.span, right.type, analyzer);
      return new BonoboObject(type, ctx.span);
    }

    if (ctx is CallExpressionContext) {
      return await resolveCallExpression(ctx, function, scope, defaultObject);
    }

    if (ctx is MemberExpressionContext) {
      return await resolveMemberExpression(ctx, scope, defaultObject);
    }

    if (ctx is TupleExpressionContext) {
      var expressions = await Future
          .wait(ctx.expressions.map((e) => resolve(e, function, scope)));
      var type = new BonoboTupleType(expressions.map((e) => e.type).toList());
      return new BonoboObject(type, ctx.span);
    }

    analyzer.errors.add(new BonoboError(
        BonoboErrorSeverity.error,
        "Cannot resolve type of expression '${ctx.span.text}' (${ctx
            .runtimeType}).",
        ctx.span));
    return defaultObject;
  }

  BonoboObject resolveNamespacedIdentifierContext(
      NamespacedIdentifierContext ctx, BonoboObject defaultObject) {
    var m = analyzer.module;

    for (var part in ctx.namespaces) {
      var child =
          m.children.firstWhere((r) => r.name == part.name, orElse: () => null);

      if (child == null) {
        analyzer.errors.add(new BonoboError(
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
      analyzer.errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "The module '${m.name}' does not contain a value named '${ctx.symbol
              .name}'.",
          ctx.symbol.span));
    } else if (symbol.visibility < Visibility.public) {
      analyzer.errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "The symbol '${ctx.symbol
              .name}' is not public. Prepend a 'pub' modifier.",
          ctx.symbol.span));
    } else {
      return symbol.value;
    }

    return defaultObject;
  }

  BonoboObject resolveMemberExpression(MemberExpressionContext ctx,
      SymbolTable<BonoboObject> scope, BonoboObject defaultObject) {
    var targetExpression = ctx.target;

    // If the target expression is neither an ID nor a member expression,
    // then we should attempt to access a field.
    if (targetExpression is! IdentifierContext) {
      // TODO: Access fields
      // For now, though, Bonobo types do not have fields.
      // https://github.com/bonobo-lang/bonobo/issues/29
      analyzer.errors.add(new BonoboError(BonoboErrorSeverity.error,
          'Bonobo types currently do not have fields', targetExpression.span));
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
    var modules = new List<BonoboModule>.from(analyzer.module.children);
    modules.addAll(analyzer.moduleSystem.rootModule.parent.children);

    // Now that we have the names of the libraries the symbol could potentially
    // be coming from, let's find the library
    var module =
        modules.firstWhere((m) => m.name == targetId.name, orElse: () => null);

    if (module == null) {
      analyzer.errors.add(new BonoboError(
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

    var correspondingSymbol =
        allSymbols.firstWhere((v) => v.name == symbolName, orElse: () => null);

    if (correspondingSymbol == null) {
      analyzer.errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "The library '${module
              .name}' has no public symbol named '$symbolName'.",
          ctx.identifier.span));
      return defaultObject;
    }

    return correspondingSymbol.value;
  }

  Future<BonoboObject> resolveCallExpression(
      CallExpressionContext ctx,
      BonoboFunction function,
      SymbolTable<BonoboObject> scope,
      BonoboObject defaultObject) async {
    var target = await resolve(ctx.target, function, scope);

    if (target is! BonoboFunction) {
      analyzer.errors.add(new BonoboError(
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

      analyzer.errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "'${f.name} expects ${f.parameters.length} $arguments, but ${ctx
              .arguments.expressions.length} $were provided.",
          ctx.span));
      return defaultObject;
    }

    bool parametersMatch = true;

    for (int i = 0; i < ctx.arguments.expressions.length; i++) {
      var p = f.parameters[i],
          arg = await resolve(ctx.arguments.expressions[i], function, scope);

      if (arg.type != BonoboType.Root && !arg.type.isAssignableTo(p.type)) {
        analyzer.errors.add(new BonoboError(
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

  Future<BonoboObject> resolveAssignmentExpression(
      AssignmentExpressionContext ctx,
      BonoboFunction function,
      SymbolTable<BonoboObject> scope,
      BonoboObject defaultObject) async {
    var leftCtx = ctx.left;

    if (leftCtx is! IdentifierContext) {
      // TODO: Do this for MemberExpression too
      analyzer.errors.add(new BonoboError(BonoboErrorSeverity.error,
          'You cannot assign a value here.', leftCtx.span));
    } else if (leftCtx is SimpleIdentifierContext) {
      var symbol = scope.resolve(leftCtx.name);

      if (symbol == null) {
        analyzer.errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            "The name '${leftCtx.name}' does not exist in this context.",
            leftCtx.span));
      } else {
        BonoboObject value;

        if (ctx.operator.type == TokenType.assign) {
          value = await resolve(ctx.right, function, scope);
        } else {
          // Make an artificial binary expression, and assign it as the value.
          var rootOperator =
              ctx.operator.span.text.substring(0, ctx.operator.span.length - 1);

          var binaryExpression = new BinaryExpressionContext(
            ctx.span,
            ctx.comments,
            leftCtx,
            ctx.right,
            BinaryOperator.fromTokenType(ctx.operator.type),
          );
          value = await resolve(binaryExpression, function, scope);
        }

        try {
          return symbol.value = value;
        } on StateError catch (e) {
          analyzer.errors.add(new BonoboError(
              BonoboErrorSeverity.error, e.message, leftCtx.span));
        }
      }
    }

    return defaultObject;
  }

  Future<BonoboObject> resolveSimpleIdentifier(SimpleIdentifierContext ctx,
      SymbolTable<BonoboObject> scope, BonoboObject defaultObject) async {
    var resolved = scope.resolve(ctx.name)?.value;

    if (resolved != null) {
      return resolved
        ..usages.add(new SymbolUsage(SymbolUsageType.declaration, ctx.span));
    }

    analyzer.errors.add(new BonoboError(BonoboErrorSeverity.error,
        "The name '${ctx.name}' does not exist in this context.", ctx.span));
    return defaultObject;
  }
}
