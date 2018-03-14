part of bonobo.src.text;

typedef ExpressionContext PrefixParselet(
    Parser parser, Token token, List<Comment> comments);

typedef ExpressionContext PostfixParselet(
    Parser parser, ExpressionContext left, Token token, List<Comment> comments);

class InfixParselet {
  final int precedence;

  final ExpressionContext Function(Parser parser, ExpressionContext left,
      Token token, List<Comment> comments) parse;

  const InfixParselet(this.precedence, this.parse);
}

class BinaryParselet extends InfixParselet {
  BinaryParselet(int precedence)
      : super(precedence, (parser, left, token, comments) {
          var span = left.span.expand(token.span);
          var right = parser.parseExpression(0);

          if (right == null) {
            parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
                "Missing expression after '${token.span.text}'.", token.span));
            return null;
          }

          span = span.expand(right.span);
          return new BinaryExpressionContext(
            left,
            token,
            right,
            span,
            []..addAll(comments)..addAll(right.comments),
          );
        });
}
