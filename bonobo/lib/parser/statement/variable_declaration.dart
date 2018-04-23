part of '../parser.dart';

class VariableDeclarationParser {
  final Parser parser;

  VariableDeclarationParser(this.parser);

  VariableDeclarationStatementContext parse({List<Comment> comments}) {
    var mutability = parseMutabilityToken(), span = mutability?.span;
    if (mutability == null) return null;

    var declarations = <VariableDeclarationContext>[],
        declaration =
            parseVariableDeclaration(comments: parser.parseComments());

    while (declaration != null) {
      declarations.add(declaration);
      span = span.expand(declaration.span);
      if (parser.nextToken(TokenType.comma) == null)
        break;
      else {
        var comma = parser.consume().span;
        span = span.expand(comma);
        declaration =
            parseVariableDeclaration(comments: parser.parseComments());

        if (declaration == null) {
          parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
              "Expected a variable declaration after ','.", comma));
          break;
        }
      }
    }

    if (declarations.isEmpty) {
      parser.errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Expected an identifier after keyword '${mutability.span.text}'.",
          mutability.span));
      return null;
    }

    var declarationSpan = span;

    var context = <StatementContext>[];
    var statement =
        parser.statementParser.parse(comments: parser.parseComments());

    while (statement != null) {
      span = span.expand(statement.span);
      context.add(statement);
      statement =
          parser.statementParser.parse(comments: parser.parseComments());
    }

    return new VariableDeclarationStatementContext(
        mutability, declarations, declarationSpan, context, span, comments);
  }

  Token parseMutabilityToken() {
    return parser.next(
        [TokenType.var_, TokenType.const_, TokenType.final_])?.removeFirst();
  }

  VariableDeclarationContext parseVariableDeclaration(
      {List<Comment> comments}) {
    var name = parser.parseSimpleIdentifier(),
        span = name?.span;
    if (name == null) return null;

    // Type annotation is optional
    TypeContext type;

    if (parser.peek()?.type == TokenType.colon) {
      var colon = parser.consume().span;

      if ((type = parser.typeParser
              .parse(ignoreComma: true, comments: parser.parseComments())) ==
          null) {
        parser.errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            "Missing type annotation after ':' in variable declaration.",
            colon));
        return null;
      }
    }

    var expression =
        parser.expressionParser.parse(0, comments: parser.parseComments());

    if (expression == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression in variable declaration.", name.span));
      return null;
    }
    span = span.expand(expression.span);

    return new VariableDeclarationContext(
        name, type, expression, span, comments ?? []);
  }
}
