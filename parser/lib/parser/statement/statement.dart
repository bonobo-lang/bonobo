part of '../parser.dart';

/*
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
    var expression = parseExpression(0, false);

    if (expression == null) {
      errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression in return statement.", span));
      return null;
    }

    return new ReturnStatementContext(
        expression, span.expand(expression.span), comments);
  }

  ExpressionStatementContext parseExpressionStatement() {
    var expression = parseExpression(0, false);
    return expression == null
        ? null
        : new ExpressionStatementContext(expression.innermost);
  }

  VariableDeclarationStatementContext parseVariableDeclarationStatement() {
    /*
    var comments = <Comment>[];
    var span = lookAhead(() {
      comments.addAll(parseComments());
      return nextToken(TokenType.v)?.span;
    });*/
    var comments = parseComments(), span = nextToken(TokenType.v)?.span;

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
    var op = nextToken(TokenType.equals) ?? nextToken(TokenType.colon_equals);

    if (op == null) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Missing '=' or ':=' after identifier in variable declaration.",
          id.span));
      return null;
    }

    span = span.expand(op.span);
    bool isFinal = op.type == TokenType.colon_equals;
    var expression = parseExpression(0, true);

    if (expression == null) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Missing expression after '${op.span.text}' in variable declaration.",
          op.span));
      return null;
    }

    return new VariableDeclarationContext(id, expression, isFinal, span, []);
  }
 */