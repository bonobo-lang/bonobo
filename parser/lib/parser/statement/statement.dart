part of '../parser.dart';

class StatementParser {
  final Parser state;

  StatementParser(this.state);

  StatementContext parse() {
    List<Comment> comments = state.parseComments();
    return varDeclarationParser.parse(comments) ??
        parseExpressionStatement() ??
        parseReturnStatement(comments);
  }

  StatementContext parseExpressionStatement() {
    ExpressionContext exp = state.parseExpression();
    if (exp == null) return null;

    Token peek = state.peek();
    if (peek == null || !isAssignToken(peek.type))
      return new ExpressionStatementContext(exp);

    AssignOperatorCtx op = new AssignOperatorCtx(
        peek.span, [], AssignOperator.fromToken(peek.type));
    state.consume();
    ExpressionContext rhs = state.parseExpression();
    if (rhs == null) return null;
    // TODO cascaded assignment

    return new AssignStatementCtx(exp.span.expand(rhs.span), [], exp, op, rhs);
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

    if (exps.length == 0)
      return new ReturnStatementContext(start.span, comments, null);

    FileSpan span = start.span.expand(exps.last.span);

    return new ReturnStatementContext(span, comments,
        new TupleLiteralCtx(exps.first.span.expand(exps.last.span), [], exps));
  }

  VarDeclarationParser _varDeclParser;
  VarDeclarationParser get varDeclarationParser =>
      _varDeclParser ??= new VarDeclarationParser(state);
}
