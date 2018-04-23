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
    if (peek == null) return null;

    AssignOperator opEnum = AssignOperator.fromToken(peek.type);
    if (opEnum == null) return new ExpressionStatementContext(exp);

    AssignOperatorContext op = new AssignOperatorContext(peek.span, [], opEnum);
    state.consume();
    ExpressionContext rhs = state.parseExpression();
    if (rhs == null) return null;

    // TODO compound assignment

    return new AssignStatementContext(
        exp.span.expand(rhs.span), [], exp, op, rhs);
  }

  ReturnStatementContext parseReturnStatement(List<Comment> comments) {
    Token start = state.nextToken(TokenType.ret);
    if (start == null) return null;

    var exp = state.parseExpression();

    if (exp == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after keyword 'ret'.", start.span));
      return null;
    }

    return new ReturnStatementContext(
        start.span.expand(exp.span), comments, exp);
  }

  VariableDeclarationParser _varDeclParser;

  VariableDeclarationParser get variableDeclarationParser =>
      _varDeclParser ??= new VariableDeclarationParser(state);
}
