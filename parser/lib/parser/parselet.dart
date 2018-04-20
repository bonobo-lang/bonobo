part of 'parser.dart';

typedef T PrefixParselet<T>(BonoboParseState parser, Token token,
    List<Comment> comments, bool inVariableDeclaration);

class InfixParselet<T> {
  final int precedence;

  final T Function(
          BonoboParseState parser, T left, Token token, List<Comment> comments)
      parse;

  const InfixParselet(this.precedence, this.parse);
}

class BinaryParselet extends InfixParselet<ExpressionContext> {
  BinaryParselet(int precedence)
      : super(precedence, (parser, left, token, comments) {
          var span = left.span.expand(token.span), lastSpan = span;
          var equals = token.type == TokenType.assign
              ? null
              : parser.nextToken(TokenType.assign)?.span;

          if (equals != null) {
            span = span.expand(lastSpan = equals);
          }

          ExpressionContext right = parser.nextExp(0);

          if (right == null) {
            parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
                "Missing expression after '${lastSpan.text}'.", lastSpan));
            return null;
          }

          span = span.expand(right.span);

          if (equals != null || token.type == TokenType.assign) {
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
            BinaryOp.fromTokenType(token.type),
            right,
            span,
            []..addAll(comments)..addAll(right.comments),
          );
        });
}
