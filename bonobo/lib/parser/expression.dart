part of 'parser.dart';

/// Pratt algorithm-based expression parser.
///
/// Supports operator precedence in an intuitive way,
/// and creates expressions that map exactly to what is/will be the spec.
class ExpressionParser {
  final Parser parser;

  ExpressionParser(this.parser);

  NumberLiteralContext parseNumberLiteral({List<Comment> comments}) =>
      const _NumberLiteralParser().parse(parser, comments: comments);

  int getPrecedence() {
    var peek = parser.peek();

    if (peek != null) {
      var infix = infixExpressionParsers
          .firstWhere((p) => p.leading == peek.type, orElse: () => null);
      if (infix != null) return infix.precedence;
    }

    return 0;
  }

  InfixParser<ExpressionContext> peekInfix(ExpressionContext left,
      {bool ignoreComma: false}) {
    var peek = parser.peek();

    if (peek != null) {
      return infixExpressionParsers.firstWhere(
          (p) =>
              p.leading == peek.type &&
              p.eligible(left, ignoreComma: ignoreComma),
          orElse: () => null);
    }

    return null;
  }

  ExpressionContext parse(int precedence,
      {List<Comment> comments, bool ignoreComma: false}) {
    // Get the first available expression.
    ExpressionContext left;

    for (var prefix in prefixParsers) {
      if ((left = prefix.parse(parser)) != null) break;
    }

    if (left == null) return null;

    while (precedence < getPrecedence()) {
      var infix = peekInfix(left, ignoreComma: ignoreComma);
      if (infix == null) break;
      left = infix.parse(parser, left,
          comments: parser.parseComments(), ignoreComma: ignoreComma);
    }

    // TODO: Postfix

    return left;
  }
}
