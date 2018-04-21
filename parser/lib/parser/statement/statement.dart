part of '../parser.dart';

class StatementParser {
  final BonoboParseState state;

  StatementParser(this.state);

  StatementContext parse() {
    List<Comment> comments = state.nextComments();
    return varDeclParser.parse() ??
        parseExpressionStatement() ??
        parseReturnStatement(comments);
  }

  StatementContext parseExpressionStatement() {
    ExpressionContext exp = state.nextExp();
    if (exp == null) return null;

    Token peek = state.peek();
    if (peek == null || !isAssignToken(peek.type))
      return new ExpressionStatementContext(exp);

    AssignOpCtx op =
        new AssignOpCtx(peek.span, [], AssignOp.fromToken(peek.type));
    state.consume();
    ExpressionContext rhs = state.nextExp();
    if (rhs == null) return null;
    // TODO cascaded assignment

    return new AssignStCtx(exp.span.expand(rhs.span), [], exp, op, rhs);
  }

  ReturnStatementContext parseReturnStatement(List<Comment> comments) {
    Token start = state.nextToken(TokenType.ret);
    if (start == null) return null;

    final exps = <ExpressionContext>[];

    for (ExpressionContext exp = state.nextExp();
        exp != null;
        exp = state.nextExp()) {
      exps.add(exp);
      if (state.nextToken(TokenType.comma) == null) break;
    }

    FileSpan span = start.span;
    if (exps.length > 0) span = span.expand(exps.last.span);

    return new ReturnStatementContext(span, comments, exps);
  }

  VarDeclParser _varDeclParser;
  VarDeclParser get varDeclParser =>
      _varDeclParser ??= new VarDeclParser(state);
}
