part of '../parser.dart';

class VariableDeclarationParser {
  final Parser state;

  VariableDeclarationParser(this.state);

  VarDeclStContext parse({VariableMutability mut}) {
    List<Comment> comments = state.nextComments();

    Token what;
    if (mut == null) {
      what =
          state.next([TokenType.const_, TokenType.let, TokenType.var_])?.removeFirst();
      if (what == null) return null;
      mut = what.type == TokenType.const_
          ? VariableMutability.const_
          : what.type == TokenType.let ? VariableMutability.final_ : VariableMutability.var_;
    } else {
      what = state.peek();
    }

    var declarations = <VariableDeclarationContext>[];

    for (VariableDeclarationContext declaration = parseADecl(mut);
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

  VariableDeclarationContext parseADecl(VariableMutability mut) {
    SimpleIdentifierContext name = state.parseSimpleIdentifier();
    if (name == null) return null;

    FileSpan lastSpan;

    // Variable type
    TypeContext type;
    if (state.peek().type == TokenType.colon) {
      state.consume();
      type = state.parseType();
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
      expression = state.parseExpression();

      if (expression == null) {
        state.errors.add(new BonoboError(
            BonoboErrorSeverity.error, "Missing initialization.", name.span));
        return null;
      }
      lastSpan = expression.span;
    }

    return new VariableDeclarationContext(
        name.span.expand(lastSpan), name, type, expression, mut, []);
  }
}
