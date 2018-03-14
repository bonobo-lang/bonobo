part of bonobo.src.text;

class Parser extends _Parser {
  Parser(Scanner scanner) : super(scanner);

  CompilationUnitContext parseCompilationUnit() {
    FileSpan span;
    var functions = <FunctionContext>[];
    FunctionContext function = parseFunction(true);

    while (!done) {
      if (function != null) {
        functions.add(function);
        span == null ? span = function.span : span = span.expand(function.span);
      } else
        consume();

      function = parseFunction(true);
    }

    if (function != null) {
      functions.add(function);
      span == null ? span = function.span : span = span.expand(function.span);
    }

    var rest = computeRest();

    if (rest.isNotEmpty) {
      var extraneous = rest.map((t) => t.span).reduce((a, b) => a.expand(b));
      errors.add(new BonoboError(
          BonoboErrorSeverity.warning, "Extraneous text.", extraneous));
    }

    return new CompilationUnitContext(span ?? scanner.emptySpan, functions);
  }

  FunctionContext parseFunction(bool requireName,
      [Token f, List<Comment> comments]) {
    comments ??= parseComments();
    f ??= nextToken(TokenType.f);
    if (f == null) return null;
    var span = f?.span, name = parseIdentifier();

    if (name == null && requireName) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing name for function.", f.span));
      return null;
    }

    span = span == null ? span : span.expand(name.span);
    var signature = parseFunctionSignature(name.span);

    span = span.expand(signature.span);
    var body = parseFunctionBody();

    if (body == null) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing function body.", signature.span));
      return null;
    }

    return new FunctionContext(
        name, signature, body, span.expand(body.span), comments);
  }

  FunctionSignatureContext parseFunctionSignature(FileSpan currentSpan) {
    var parameterList = parseParameterList();
    var span = parameterList?.span, colon;
    TypeContext returnType;

    if ((colon = nextToken(TokenType.colon)) != null) {
      span = span == null ? colon.span : span.expand(colon.span);

      if ((returnType = parseType()) == null) {
        errors.add(new BonoboError(
            BonoboErrorSeverity.error, "Missing type after ':'.", colon.span));
      } else
        span = span.expand(returnType.span);
    }

    return new FunctionSignatureContext(
        parameterList, returnType, span ?? currentSpan, []);
  }

  ParameterListContext parseParameterList() {
    var closedParen = nextToken(TokenType.parentheses)?.span;

    if (closedParen != null) {
      return new ParameterListContext([], closedParen, []);
    }

    var lParen = nextToken(TokenType.lParen);
    if (lParen == null) return null;
    var span = lParen.span, lastSpan = span;
    var parameters = <ParameterContext>[];
    ParameterContext parameter = parseParameter();

    while (parameter != null) {
      parameters.add(parameter);
      span = span.expand(lastSpan = parameter.span);

      if (nextToken(TokenType.comma) != null) {
        parameter = parseParameter();
      } else {
        break;
      }
    }

    var rParen = nextToken(TokenType.rParen);

    if (rParen == null) {
      errors.add(
          new BonoboError(BonoboErrorSeverity.error, "Missing ')'.", lastSpan));
      return null;
    }

    span = span.expand(rParen.span);

    return new ParameterListContext(parameters, span, []);
  }

  ParameterContext parseParameter() {
    var id = parseIdentifier();
    if (id == null) return null;
    var span = id.span, colon = nextToken(TokenType.colon);
    TypeContext type;

    if (colon != null) {
      span = span.expand(colon.span);

      if ((type = parseType()) == null) {
        errors.add(new BonoboError(
            BonoboErrorSeverity.error, "Missing type after ':'.", colon.span));
      } else
        span = span.expand(type.span);
    }

    return new ParameterContext(id, type, span, []);
  }

  FunctionBodyContext parseFunctionBody() {
    return parseLambdaFunctionBody() ?? parseBlockFunctionBody();
  }

  BlockFunctionBodyContext parseBlockFunctionBody() {
    var block = parseBlock();
    return block == null ? null : new BlockFunctionBodyContext(block);
  }

  BlockContext parseBlock() {
    var span = nextToken(TokenType.lCurly)?.span, lastSpan = span;
    if (span == null) return null;
    var statements = <StatementContext>[];
    var statement = parseStatement();

    while (!done) {
      if (statement != null) {
        statements.add(statement);
        span = span.expand(lastSpan = statement.span);
      }

      if ((statement = parseStatement()) == null) {
        if (peek()?.type == TokenType.rCurly)
          break;
        else
          statement = parseStatement();
      }
    }

    var rCurly = consume();

    if (rCurly?.type != TokenType.rCurly) {
      errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing '}' in function body.", lastSpan));
      return null;
    }

    return new BlockContext(statements, span.expand(rCurly.span), []);
  }

  LambdaFunctionBodyContext parseLambdaFunctionBody() {
    var arrow = nextToken(TokenType.arrow);

    if (arrow != null) {
      var expression = parseExpression(0);

      if (expression == null) {
        errors.add(new BonoboError(BonoboErrorSeverity.error,
            "Missing expression after '=>'.", arrow.span));
        return null;
      } else {
        return new LambdaFunctionBodyContext(
            expression, arrow.span.expand(expression.span), []);
      }
    } else
      return null;
  }

  TypeContext parseType() {
    return parseIdentifierType();
  }

  IdentifierTypeContext parseIdentifierType() {
    var id = parseIdentifier();
    return id == null ? null : new IdentifierTypeContext(id, []);
  }

  IdentifierContext parseIdentifier() {
    var id = nextToken(TokenType.identifier);
    return id == null ? null : new IdentifierContext(id.span, []);
  }

  ExpressionContext parseExpression(int precedence) {
    //var comments = parseComments();
    Token token = peek();

    if (token == null) return null;

    PrefixParselet prefix = _prefixParselets[token.type];

    if (prefix == null) {
      /*
      errors.add(new BonoboError(BonoboErrorSeverity.error,
          'Expected expression, found "${token.span.text}".', token.span));
          */
      return null;
    }

    consume();

    var left = prefix(this, token, []);

    while (precedence < getPrecedence() && left != null) {
      token = consume();

      InfixParselet infix = _infixParselets[token.type];
      left = infix.parse(this, left, token, []);
    }

    // TODO: Support this logic for MemberExpression
    if (left is IdentifierContext) {
      // See https://github.com/bonobo-lang/bonobo/issues/9.
      var arg = parseExpression(0);

      if (arg != null) {
        var span = left.span.expand(arg.span);

        if (arg.innermost is! TupleExpressionContext) {
          left = new CallExpressionContext(
            left,
            new TupleExpressionContext(
              [arg],
              arg.span,
              [],
            ),
            span,
            [],
          );
        } else {
          left = new CallExpressionContext(
            left,
            arg.innermost,
            span,
            [],
          );
        }
      }
    }

    return left;
  }

  StatementContext parseStatement() {
    return parseVariableDeclarationStatement() ??
        parseReturnStatement() ??
        parseExpressionStatement();
  }

  ReturnStatementContext parseReturnStatement() {
    var comments = <Comment>[];
    var span = lookAhead(() {
      comments.addAll(parseComments());
      return nextToken(TokenType.ret)?.span;
    });

    if (span == null) return null;
    var expression = parseExpression(0);

    if (expression == null) {
      errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression in return statement.", span));
      return null;
    }

    return new ReturnStatementContext(
        expression, span.expand(expression.span), comments);
  }

  ExpressionStatementContext parseExpressionStatement() {
    var expression = parseExpression(0);
    return expression == null
        ? null
        : new ExpressionStatementContext(expression.innermost);
  }

  VariableDeclarationStatementContext parseVariableDeclarationStatement() {
    var comments = <Comment>[];
    var span = lookAhead(() {
      comments.addAll(parseComments());
      return nextToken(TokenType.v)?.span;
    });

    //var lastSpan = span;
    if (span == null) return null;

    var declarations = <VariableDeclarationContext>[];
    var declaration = parseVariableDeclaration();

    while (declaration != null) {
      declarations.add(declaration);
      span = span.expand(declaration.span);

      if (nextToken(TokenType.comma) == null)
        break;
      else
        declaration = parseVariableDeclaration();
    }

    if (declarations.isEmpty) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error, 'Expected an identifier.', span));
      return null;
    }

    var declSpan = span;

    // Parse any statements after this one.
    // They all share a scope.
    var statements = <StatementContext>[];
    StatementContext statement = parseStatement();

    while (!done) {
      if (statement != null) {
        statements.add(statement);
        span = span.expand(statement.span);
      }

      if (peek()?.type == TokenType.rCurly) break;
      statement = parseStatement();
    }

    return new VariableDeclarationStatementContext(
        declarations, statements, declSpan, span, comments);
  }

  VariableDeclarationContext parseVariableDeclaration() {
    var id = parseIdentifier();
    if (id == null) return null;
    var span = id.span;
    var op = nextToken(TokenType.colon_equals) ?? nextToken(TokenType.equals);

    if (op == null) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Missing '=' or ':=' after identifier in variable declaration.",
          id.span));
      return null;
    }

    span = span.expand(op.span);
    bool isFinal = op.type == TokenType.colon_equals;

    var expression = parseExpression(0);

    if (expression == null) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Missing expression after '${op.span.text}' in variable declaration.",
          op.span));
      return null;
    }

    return new VariableDeclarationContext(id, expression, isFinal, span, []);
  }
}
