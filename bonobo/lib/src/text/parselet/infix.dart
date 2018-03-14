part of bonobo.src.text;

final Map<TokenType, InfixParselet> _infixParselets = {
  // Parse tuples
  TokenType.comma: new InfixParselet(1, (parser, left, token, comments) {
    var span = left.span.expand(token.span);
    var right = parser.parseExpression(0);

    if (right == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after ','", token.span));
      return null;
    }

    span = span.expand(right.span);

    if (left is TupleExpressionContext) {
      return new TupleExpressionContext(
        []
          ..addAll(left.expressions)
          ..add(right),
        span,
        []..addAll(left.comments)..addAll(comments),
      );
    }

    return new TupleExpressionContext([left, right], span, comments);
  }),

  // Parse arg-less calls
  TokenType.parentheses: new InfixParselet(2, (parser, left, token, comments) {
    return new CallExpressionContext(
      left,
      new TupleExpressionContext([], token.span, []),
      left.span.expand(token.span),
      []..addAll(left.comments)..addAll(comments),
    );
  }),
};
