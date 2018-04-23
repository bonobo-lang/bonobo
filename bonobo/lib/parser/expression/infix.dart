part of '../parser.dart';

/// Infix/postfix parsers.
abstract class InfixParser<T extends AstNode> {
  TokenType get leading;

  int get precedence;

  bool eligible({bool ignoreComma: false});

  T parse(Parser parser, T left,
      {List<Comment> comments, bool ignoreComma: false});
}

final List<InfixParser<ExpressionContext>> infixExpressionParsers =
    _createInfixExpressionParsers();

List<InfixParser<ExpressionContext>> _createInfixExpressionParsers() {
  var parsers = <InfixParser<ExpressionContext>>[];
  int precedence = 0;

  void addBinary(List<TokenType> types) {
    int p = precedence++;

    for (var type in types) {
      parsers.add(new _BinaryExpressionParser(type, p));
    }
  }

  addBinary([TokenType.pow]);

  addBinary([TokenType.times, TokenType.div, TokenType.mod]);

  addBinary([TokenType.plus, TokenType.minus]);

  // TODO: Bitwise operators

  // TODO: Boolean operators

  // TODO: Call expressions

  parsers.add(new _TupleExpressionParser(precedence++));

  return parsers;
}

class _TupleExpressionParser implements InfixParser<ExpressionContext> {
  final int precedence;

  const _TupleExpressionParser(this.precedence);

  @override
  bool eligible({bool ignoreComma: false}) => !ignoreComma;

  @override
  TokenType get leading => TokenType.comma;

  @override
  ExpressionContext parse(Parser parser, ExpressionContext left,
      {List<Comment> comments, bool ignoreComma: false}) {
    if (ignoreComma) return null;
    if (parser.peek()?.type != leading) return null;

    var comma = parser.consume(),
        lastSpan = comma.span,
        span = left.span.expand(lastSpan);
    var right = parser.expressionParser
        .parse(0, comments: parser.parseComments(), ignoreComma: false);

    if (right == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after ','.", lastSpan));
      return null;
    }

    span = span.expand(lastSpan = right.span);

    // Either combine two tuples, or make a new tuple.
    if (right is TupleExpressionContext) {
      return new TupleExpressionContext(
          []
            ..add(left)
            ..addAll(right.expressions),
          span,
          comments ?? []);
    }

    return new TupleExpressionContext([left.innermost, right.innermost], span, comments ?? []);
  }
}

// TODO: Support upgrade to assignment
class _BinaryExpressionParser implements InfixParser<ExpressionContext> {
  final TokenType leading;
  final int precedence;

  const _BinaryExpressionParser(this.leading, this.precedence);

  @override
  bool eligible({bool ignoreComma: false}) => true;

  @override
  ExpressionContext parse(Parser parser, ExpressionContext left,
      {List<Comment> comments, bool ignoreComma: false}) {
    if (parser.peek()?.type != leading) return null;

    var op = parser.consume(), span = op.span, lastSpan = span;
    var right = parser.expressionParser
        .parse(0, comments: parser.parseComments(), ignoreComma: ignoreComma);

    if (right == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after '${lastSpan.text}'.", lastSpan));
      return null;
    }

    return new BinaryExpressionContext(left, right, op, span, comments ?? []);
  }
}
