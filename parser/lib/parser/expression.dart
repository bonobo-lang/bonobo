part of 'parser.dart';

/// Pratt algorithm-based expression parser.
///
/// Supports operator precedence in an intuitive way,
/// and creates expressions that map exactly to what is/will be the spec.
class ExpressionParser {
  final Parser parser;

  ExpressionParser(this.parser);

  ExpressionContext parse(int precedence,
      {List<Comment> comments, bool ignoreComma: false}) {
    // Get the first available expression.
    ExpressionContext left;

    for (var prefix in prefixParsers) {
      if ((left = prefix.parse(parser)) != null) break;
    }

    if (left == null) return null;

    // TODO: Infix

    // TODO: Postfix

    return left;
  }
}
