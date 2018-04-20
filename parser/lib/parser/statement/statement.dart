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

class VarDeclParser {
  final BonoboParseState state;

  VarDeclParser(this.state);

  VarDeclStContext parse() {
    var comments = <Comment>[];

    Token what = state.lookAhead(() {
      comments.addAll(state.nextComments());
      return state
          .nextIfOneOf([TokenType.const_, TokenType.let, TokenType.var_]);
    });
    if (what == null) return null;

    VarMut mut = what.type == TokenType.const_
        ? VarMut.const_
        : what.type == TokenType.let ? VarMut.final_ : VarMut.var_;

    var declarations = <VarDeclContext>[];

    for (VarDeclContext declaration = parseADecl(mut);
        declaration != null;
        declaration = parseADecl(mut)) {
      declarations.add(declaration);
      if (state.nextToken(TokenType.comma) == null) break;
    }

    if (declarations.isEmpty) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error, 'Expected an identifier.', what.span));
      return null;
    }

    return new VarDeclStContext(what.span, mut, declarations, comments);
  }

  VarDeclContext parseADecl(VarMut mut) {
    SimpleIdentifierContext name = state.nextSimpleId();
    if (name == null) return null;

    FileSpan lastSpan;

    // Variable type
    TypeContext type;
    if (state.peek().type == TokenType.colon) {
      state.consume();
      type = state.nextType();
      // TODO error message
      if (type == null) return null;
      lastSpan = type.span;
    }

    ExpressionContext expression;
    if (state.nextToken(TokenType.assign) == null) {
      if (type == null) {
        state.errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            "Variable declaration requires type annotation or initialization.",
            name.span));
        return null;
      }
    } else {
      expression = state.nextExp(0);

      if (expression == null) {
        state.errors.add(new BonoboError(
            BonoboErrorSeverity.error, "Missing initialization.", name.span));
        return null;
      }
      lastSpan = expression.span;
    }

    return new VarDeclContext(
        name.span.expand(lastSpan), name, type, expression, mut, []);
  }
}
