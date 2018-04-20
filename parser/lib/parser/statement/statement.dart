part of '../parser.dart';

class StatementParser {
  final BonoboParseState state;

  StatementParser(this.state);

  StatementContext parse() {
    return varDeclParser.parse() ??
        parseExpressionStatement() ??
        parseReturnStatement();
  }

  ExpressionStatementContext parseExpressionStatement() {
    ExpressionContext exp = state.nextExp(0);
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

    ExpressionContext exp = state.nextExp(0);

    if (exp == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression in return statement.", span));
      return null;
    }

    // TODO comments on same line also belong to this statement

    return new ReturnStatementContext(exp, span.expand(exp.span), comments);
  }

  VarDeclParser _varDeclParser;
  VarDeclParser get varDeclParser =>
      _varDeclParser ??= new VarDeclParser(state);
}
