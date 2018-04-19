part of '../parser.dart';

class StatementParser {
  final BonoboParseState state;

  StatementParser(this.state);

  StatementContext parse() {
    return parseVariableDeclarationStatement() ??
        parseExpressionStatement() ??
        parseReturnStatement();
  }

  ExpressionStatementContext parseExpressionStatement() {
    ExpressionContext exp = state.nextExp(0, false);
    if (exp == null) return null;
    return new ExpressionStatementContext(exp.innermost);
  }

  ReturnStatementContext parseReturnStatement() {
    var comments = <Comment>[];

    FileSpan span = state.lookAhead(() {
      comments.addAll(state.nextComments());
      return state.nextToken(TokenType.ret)?.span;
    });
    if (span == null) return null;

    ExpressionContext exp = state.nextExp(0, false);

    if (exp == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression in return statement.", span));
      return null;
    }

    // TODO comments on same line also belong to this statement

    return new ReturnStatementContext(exp, span.expand(exp.span), comments);
  }

  VariableDeclarationStatementContext parseVariableDeclarationStatement() {
    var comments = <Comment>[];
    FileSpan span = state.lookAhead(() {
      comments.addAll(state.nextComments());
      return state.nextToken(TokenType.v)?.span;
    });

    if (span == null) return null;

    var declarations = <VariableDeclarationContext>[];

    for (VariableDeclarationContext declaration = parseVariableDeclaration();
        declaration != null;
        declaration = parseVariableDeclaration()) {
      declarations.add(declaration);
      if (state.nextToken(TokenType.comma) == null) break;
    }

    if (declarations.isEmpty) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error, 'Expected an identifier.', span));
      return null;
    }

    /*
    FileSpan declSpan = span;

    // Parse any statements after this one.
    // They all share a scope.
    var statements = <StatementContext>[];
    StatementContext statement = parse();

    while (!state.done) {
      if (statement != null) {
        statements.add(statement);
      }

      if (state.peek()?.type == TokenType.rCurly) break;
      statement = parse();
    }
    */

    return new VariableDeclarationStatementContext(
        declarations, span, comments);
  }

  VariableDeclarationContext parseVariableDeclaration() {
    SimpleIdentifierContext id = state.nextSimpleId();
    if (id == null) return null;

    // TODO type annotation?

    Token op = state.nextIfOneOf([TokenType.equals, TokenType.colon_equals]);

    if (op == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Missing '=' or ':=' after identifier in variable declaration.",
          id.span));
      return null;
    }

    bool isFinal = op.type == TokenType.colon_equals;
    ExpressionContext expression = state.nextExp(0, true);

    if (expression == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Missing expression after '${op.span.text}' in variable declaration.",
          op.span));
      return null;
    }

    return new VariableDeclarationContext(
        id, expression, isFinal, id.span.expand(expression.span), []);
  }
}
