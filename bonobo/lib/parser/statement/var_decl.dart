part of '../parser.dart';

class VariableDeclarationParser {
  final Parser parser;

  VariableDeclarationParser(this.parser);

  VariableDeclarationStatementContext parse({VariableMutability mut}) {
    List<Comment> comments = parser.parseComments();

    Token what;
    if (mut == null) {
      what = parser.next(
          [TokenType.const_, TokenType.let, TokenType.var_])?.removeFirst();
      if (what == null) return null;
      mut = what.type == TokenType.const_
          ? VariableMutability.const_
          : what.type == TokenType.let
              ? VariableMutability.final_
              : VariableMutability.var_;
    } else {
      what = parser.peek();
    }

    var declarations = <VariableDeclarationContext>[];

    for (VariableDeclarationContext declaration = parseADecl();
        declaration != null;
        declaration = parseADecl()) {
      declarations.add(declaration);
      if (parser.nextToken(TokenType.comma) == null) break;
    }

    if (declarations.isEmpty) {
      parser.errors.add(new BonoboError(
          BonoboErrorSeverity.error, 'Expected an identifier.', what.span));
      return null;
    }

    var declarationSpan = what.span.expand(declarations.last.span);
    var context = <StatementContext>[];
    var statement = parser.parseStatement();
    var span = declarationSpan;

    while (statement != null) {
      span = span.expand(statement.span);
      context.add(statement);
      statement = parser.parseStatement();
    }

    return new VariableDeclarationStatementContext(
        mut, declarations, declarationSpan, context, span, comments);
  }

  VariableDeclarationContext parseADecl() {
    var comments = parser.parseComments();
    var name = parser.parseSimpleIdentifier(),
        span = name?.span,
        lastSpan = span;
    if (name == null) return null;

    /*
    // Variable type
    TypeContext type;
    if (state.peek().type == TokenType.colon) {
      state.consume();
      type = state.typeParser
          .parse(comments: state.parseComments(), ignoreComma: true);
      // TODO error message
      if (type == null) return null;
      span = span.expand(lastSpan = type.span);
    }*/

    ExpressionContext expression;
    /*if (state.nextToken(TokenType.assign) == null) {
      if (type == null) {
        state.errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            "Variable declaration requires type annotation or initialization.",
            name.span));
        return null;
      }
    } else {*/
    expression = parser.expressionParser.parse(0, comments: parser.parseComments());

    if (expression == null) {
      parser.errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing initialization.", name.span));
      return null;
    }
    span = span.expand(lastSpan = expression.span);
    //}

    return new VariableDeclarationContext(name, expression, span, comments);
  }
}
