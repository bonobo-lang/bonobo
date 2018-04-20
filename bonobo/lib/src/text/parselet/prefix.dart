part of bonobo.src.text;

// TODO: +, -
// TODO: ++, --
// TODO: ~

final Map<TokenType, PrefixParselet<ExpressionContext>> _prefixParselets = {
  // Literals
  TokenType.string: (_, token, comments, __) =>
      new StringLiteralContext(token.span, comments),
  TokenType.number: (_, token, comments, __) =>
      new NumberLiteralContext(token.span, comments),
  //TokenType.identifier: (p, token, comments, __) => p.parseIdentifier(token),
  //new SimpleIdentifierContext(token.span, comments),

  // Reserved words
  TokenType.lambda: (parser, token, comments, __) =>
      parser.parseFunction(false, token, comments),
  TokenType.print: (parser, token, comments, bool inVariableDeclaration) {
    var expression = parser.parseExpression(0, inVariableDeclaration);

    if (expression == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after 'print'.", token.span));
      return null;
    }

    return new PrintExpressionContext(
        expression, token.span.expand(expression.span), comments);
  },

  // Operators
  TokenType.lParen: (parser, token, comments, _) {
    // The parentheses make it OK to include a tuple in a variable declaration.
    //
    // So `inVariableDeclaration` will be `false`.
    var expression = parser.parseExpression(0, false);

    if (expression == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after '('.", token.span));
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