part of bonobo.src.text;

final Map<TokenType, PrefixParselet<TypeContext>> _typePrefixParselets = {
  TokenType.identifier: (parser, token, comments, inVariableDeclaration) {
    var parts = <Token>[token];
    var span = token.span;

    while (parser.peek()?.type == TokenType.double_colon) {
      var colon = parser.consume();
      span = span.expand(colon.span);

      if (parser.peek()?.type != TokenType.identifier) {
        return null;
      }

      var id = parser.nextToken(TokenType.identifier);
      span = span.expand(id.span);
    }

    if (parts.length == 1) {
      return new SimpleIdentifierTypeContext(
          new SimpleIdentifierContext(span, []), comments);
    }

    var ids = parts.map((t) => new SimpleIdentifierContext(t.span, []));

    return new NamespacedIdentifierTypeContext(
      new NamespacedIdentifierContext(
        ids.take(ids.length - 1).toList(),
        ids.last,
        span,
        [],
      ),
      comments,
    );
  },
  TokenType.lParen: (parser, token, comments, inVariableDeclaration) {
    var type = parser.parseType(0, false);

    if (type == null) {
      parser.errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing type after '('.", token.span));
      return null;
    }

    var span = token.span.expand(type.span);
    var rParen = parser.nextToken(TokenType.rParen)?.span;

    if (rParen == null && parser.peek()?.type == TokenType.rParen) {
      rParen = parser.consume().span;
    }

    if (rParen == null) {
      parser.errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing ')' after type.", token.span));
      return null;
    }

    return new ParenthesizedTypeContext(type, span.expand(rParen), comments);
  },
};

final Map<TokenType, InfixParselet<TypeContext>> _typeInfixParselets =
    createTypeInfixParselets();

Map<TokenType, InfixParselet<TypeContext>> createTypeInfixParselets() {
  int precedence = 1;

  return {
    // Parse tuples
    TokenType.comma: new InfixParselet(precedence++,
        (parser, left, token, comments, inVariableDeclaration) {
      if (inVariableDeclaration) {
        return left;
      }

      var span = left.span.expand(token.span);
      var right = parser.parseType(0, inVariableDeclaration);
      var innermost = right.innermost;

      if (right == null) {
        parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
            "Missing type after ','", token.span));
        return null;
      }

      span = span.expand(right.span);

      if (right is! ParenthesizedTypeContext &&
          innermost is TupleTypeContext) {
        return new TupleTypeContext(
          []
            ..add(left)
            ..addAll(innermost.items),
          span,
          []..addAll(left.comments)..addAll(comments),
        );
      }

      return new TupleTypeContext([left, right], span, comments);
    }),
  };
}
