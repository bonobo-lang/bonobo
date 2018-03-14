part of bonobo.src.text;

final Map<TokenType, PrefixParselet> _prefixParselets = {
  // Literals
  TokenType.string: (_, token, comments) =>
      new StringLiteralContext(token.span, comments),
  TokenType.number: (_, token, comments) =>
      new NumberLiteralContext(token.span, comments),
  TokenType.identifier: (_, token, comments) =>
      new IdentifierContext(token.span, comments),

  // Reserved words
  TokenType.f: (parser, token, comments) =>
      parser.parseFunction(false, token, comments),
  TokenType.print: (parser, token, comments) {
    var expression = parser.parseExpression(0);

    if (expression == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after 'print'.", token.span));
      return null;
    }

    return new PrintExpressionContext(
        expression, token.span.expand(expression.span), comments);
  },

  // Operators
  TokenType.lParen: (parser, token, comments) {
    var expression = parser.parseExpression(0);

    if (expression == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after ')'.", token.span));
      return null;
    }

    var span = token.span.expand(expression.span);
    var rParen = parser.nextToken(TokenType.rParen)?.span;

    if (rParen == null && parser.peek()?.type == TokenType.rParen) {
        rParen = parser.consume().span;
    }

    if (rParen == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing ')' after expression.", token.span));
      return null;
    }

    return new ParenthesizedExpressionContext(
        expression, span.expand(rParen), comments);
  }
};
