part of '../parser.dart';

class StatementParser {
  final Parser parser;

  StatementParser(this.parser);

  StatementContext parse() {
    List<Comment> comments = parser.parseComments();
    return variableDeclarationParser.parse() ??
        parseExpressionStatement() ??
        parseReturnStatement(comments);
  }

  StatementContext parseExpressionStatement() {
    ExpressionContext exp = parser.expressionParser.parse(0, comments: parser.parseComments());
    if (exp == null) return null;

    Token peek = parser.peek();
    if (peek == null) return null;

    AssignOperator opEnum = AssignOperator.fromToken(peek.type);
    if (opEnum == null) return new ExpressionStatementContext(exp);

    AssignOperatorContext op = new AssignOperatorContext(peek.span, [], opEnum);
    parser.consume();
    ExpressionContext rhs = parser.expressionParser.parse(0, comments: parser.parseComments());
    if (rhs == null) return null;

    // TODO compound assignment

    return new AssignStatementContext(
        exp.span.expand(rhs.span), [], exp, op, rhs);
  }

  ReturnStatementContext parseReturnStatement(List<Comment> comments) {
    Token start = parser.nextToken(TokenType.ret);
    if (start == null) return null;

    var exp = parser.expressionParser.parse(0, comments: parser.parseComments());

    if (exp == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after keyword 'ret'.", start.span));
      return null;
    }

    return new ReturnStatementContext(
        start.span.expand(exp.span), comments, exp);
  }

  VariableDeclarationParser _varDeclParser;

  VariableDeclarationParser get variableDeclarationParser =>
      _varDeclParser ??= new VariableDeclarationParser(parser);
}