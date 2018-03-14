part of bonobo.src.text;

final Map<TokenType, InfixParselet> _infixParselets = {
  TokenType.lParen: new InfixParselet(1, (parser, left, token, comments) {
    var arguments = <ExpressionContext>[];
    var span = left.span.expand(token.span), lastSpan = span;
    var argument = parser.parseExpression(0);

    while (!parser.done) {
      if (argument != null) {
        arguments.add(argument);
        span = span.expand(lastSpan = argument.span);
      }

      if (parser.nextToken(TokenType.comma) != null)
        argument = parser.parseExpression(0);
      else
        break;
    }

    var rParen = parser.nextToken(TokenType.rParen)?.span;

    if (rParen == null) {
      parser.errors.add(
          new BonoboError(BonoboErrorSeverity.error, "Missing ')'.", lastSpan));
      return null;
    }

    return new CallExpressionContext(
        left, arguments, span.expand(rParen), comments);
  }),
};
