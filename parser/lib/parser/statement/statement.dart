part of '../parser.dart';

class StatementParser {
  final Parser state;

  StatementParser(this.state);

  StatementContext parse() {
    List<Comment> comments = state.parseComments();
    return variableDeclarationParser.parse() ??
        parseExpressionStatement() ??
        parseReturnStatement(comments);
  }

  StatementContext parseExpressionStatement() {
    ExpressionContext exp = state.parseExpression();
    if (exp == null) return null;

    Token peek = state.peek();
    if (peek == null || !isAssignToken(peek.type))
      return new ExpressionStatementContext(exp);

    AssignmentOperatorContext op =
        new AssignmentOperatorContext(peek.span, [], AssignmentOperator.fromToken(peek.type));
    state.consume();
    ExpressionContext rhs = state.parseExpression();
    if (rhs == null) return null;
    // TODO cascaded assignment

    return new AssignStCtx(exp.span.expand(rhs.span), [], exp, op, rhs);
  }

  ReturnStatementContext parseReturnStatement(List<Comment> comments) {
    Token start = state.nextToken(TokenType.ret);
    if (start == null) return null;

    final exps = <ExpressionContext>[];

    for (ExpressionContext exp = state.parseExpression();
        exp != null;
        exp = state.parseExpression()) {
      exps.add(exp);
      if (state.nextToken(TokenType.comma) == null) break;
    }

    FileSpan span = start.span;
    if (exps.length > 0) span = span.expand(exps.last.span);

    return new ReturnStatementContext(span, comments, exps);
  }

  VariableDeclarationParser _varDeclParser;
  VariableDeclarationParser get variableDeclarationParser =>
      _varDeclParser ??= new VariableDeclarationParser(state);
}
