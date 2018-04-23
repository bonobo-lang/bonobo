part of 'parser.dart';

/// Pratt algorithm-based expression parser.
///
/// Supports operator precedence in an intuitive way,
/// and creates expressions that map exactly to what is/will be the spec.
class ExpressionParser {
  final Parser parser;

  ExpressionParser(this.parser);

  ExpressionContext parse({List<Comment> comments, bool ignoreComma: false}) {
    
  }
}