part of '../parser.dart';

class VarDeclParser {
  final BonoboParseState state;

  VarDeclParser(this.state);

  VarDeclStContext parse({VarMut mut}) {
    List<Comment> comments = state.nextComments();

    Token what;
    if (mut == null) {
      what =
          state.nextIfOneOf([TokenType.const_, TokenType.let, TokenType.var_]);
      if (what == null) return null;
      mut = what.type == TokenType.const_
          ? VarMut.const_
          : what.type == TokenType.let ? VarMut.final_ : VarMut.var_;
    } else {
      what = state.peek();
    }

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

    return new VarDeclStContext(
        what.span.expand(declarations.last.span), mut, declarations, comments);
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
