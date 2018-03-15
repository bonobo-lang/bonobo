part of bonobo.src.text;

typedef ExpressionContext PrefixParselet(
    Parser parser, Token token, List<Comment> comments, bool inVariableDeclaration);

class InfixParselet {
  final int precedence;

  final ExpressionContext Function(Parser parser, ExpressionContext left,
      Token token, List<Comment> comments, bool inVariableDeclaration) parse;

  const InfixParselet(this.precedence, this.parse);
}

class BinaryParselet extends InfixParselet {
  BinaryParselet(int precedence)
      : super(precedence, (parser, left, token, comments, inVariableDeclaration) {
          var span = left.span.expand(token.span), lastSpan = span;
          var equals = parser.nextToken(TokenType.equals)?.span;

          if (equals != null) {
            span = span.expand(lastSpan = equals);
          }

          var right = parser.parseExpression(0, inVariableDeclaration);

          if (right == null) {
            parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
                "Missing expression after '${lastSpan.text}'.", lastSpan));
            return null;
          }

          span = span.expand(right.span);

          if (equals != null) {
            return new AssignmentExpressionContext(
              left,
              token,
              right,
              span,
              []..addAll(comments)..addAll(right.comments),
            );
          }

          return new BinaryExpressionContext(
            left,
            token,
            right,
            span,
            []..addAll(comments)..addAll(right.comments),
          );
        });
}
