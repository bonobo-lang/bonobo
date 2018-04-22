part of '../parser.dart';

class VarDeclarationParser {
  final Parser state;

  VarDeclarationParser(this.state);

  VarDeclarationStatementContext parse(List<Comment> comments,
      {VariableMutability mut}) {
    Token what;
    if (mut == null) {
      what =
          state.nextIfOneOf([TokenType.const_, TokenType.let, TokenType.var_]);
      if (what == null) return null;
      mut = what.type == TokenType.const_
          ? VariableMutability.const_
          : what.type == TokenType.let
              ? VariableMutability.final_
              : VariableMutability.var_;
    } else {
      what = state.peek();
    }

    var declarations = <VarDeclarationContext>[];

    for (VarDeclarationContext declaration = parseADecl(mut);
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

    return new VarDeclarationStatementContext(
        what.span.expand(declarations.last.span), comments, mut, declarations);
  }

  VarDeclarationContext parseADecl(VariableMutability mut) {
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

    return new VarDeclarationContext(
        name.span.expand(lastSpan), [], mut, name, type, expression);
  }
}
