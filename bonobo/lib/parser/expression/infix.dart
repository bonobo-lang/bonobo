part of '../parser.dart';

/// Infix/postfix parsers.
abstract class InfixParser<T extends AstNode> {
  TokenType get leading;

  int get precedence;

  bool eligible(T left, {bool ignoreComma: false});

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

  parsers.add(new _MemberExpressionParser(precedence++));

  parsers.add(new _TupleExpressionParser(precedence++));

  parsers.add(new _CallExpressionParser(precedence++));

  parsers
      .add(new _RangeLiteralParser(precedence++, TokenType.double_dot, false));
  parsers
      .add(new _RangeLiteralParser(precedence++, TokenType.triple_dot, true));

  return parsers;
}

class _RangeLiteralParser implements InfixParser<ExpressionContext> {
  final int precedence;
  final TokenType leading;
  final bool exclusive;

  const _RangeLiteralParser(this.precedence, this.leading, this.exclusive);

  @override
  bool eligible(ExpressionContext left, {bool ignoreComma: false}) => true;

  @override
  ExpressionContext parse(Parser parser, ExpressionContext left,
      {List<Comment> comments, bool ignoreComma: false}) {
    if (parser.peek()?.type != leading) return null;

    var dots = parser.consume(),
        lastSpan = dots.span,
        span = left.span.expand(lastSpan);

    var right = parser.expressionParser
        .parse(0, comments: parser.parseComments(), ignoreComma: true);

    if (right == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after '${dots.span.text}'.", lastSpan));
      return null;
    }

    span = span.expand(lastSpan = right.span);

    ExpressionContext step;

    if (parser.peek()?.type == TokenType.comma) {
      var comma = parser.consume();
      span = span.expand(lastSpan = comma.span);

      step = parser.expressionParser.parse(0, comments: parser.parseComments());

      if (step == null) {
        parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
            "Missing expression after ','.", lastSpan));
        return null;
      }

      span = span.expand(lastSpan = step.span);
    }

    return new RangeLiteralContext(
        left, right, step, exclusive, span, comments ?? []);
  }
}

class _CallExpressionParser implements InfixParser<ExpressionContext> {
  final int precedence;

  const _CallExpressionParser(this.precedence);

  @override
  TokenType get leading => TokenType.lParen;

  @override
  bool eligible(ExpressionContext left, {bool ignoreComma: false}) => true;

  @override
  ExpressionContext parse(Parser parser, ExpressionContext left,
      {List<Comment> comments, bool ignoreComma: false}) {
    var lParen = parser.nextToken(TokenType.lParen)?.span;

    if (lParen == null) return null;

    FileSpan lastSpan = lParen, span = left.span.expand(lastSpan), exprSpan;
    var expressions = <ExpressionContext>[];

    var expression = parser.expressionParser
        .parse(0, comments: parser.parseComments(), ignoreComma: true);

    while (expression != null) {
      expressions.add(expression);
      span = span.expand(exprSpan =
          (exprSpan ??= expression.span).expand(lastSpan = expression.span));
      if (parser.peek()?.type != TokenType.comma) break;

      var comma = parser.consume().span;
      exprSpan = exprSpan.expand(lastSpan = comma);

      if ((expression = parser.expressionParser
              .parse(0, comments: parser.parseComments())) ==
          null) {
        parser.errors.add(new BonoboError(
            BonoboErrorSeverity.error, "Missing expression after ','.", comma));
        return null;
      }
    }

    var rParen = parser.nextToken(TokenType.rParen)?.span;

    if (rParen == null) {
      parser.errors.add(
          new BonoboError(BonoboErrorSeverity.error, "Missing ')'.", lastSpan));
      return null;
    }

    return new CallExpressionContext(
        left,
        new TupleExpressionContext(expressions, exprSpan, []),
        span.expand(rParen),
        comments ?? []);
  }
}

class _MemberExpressionParser implements InfixParser<ExpressionContext> {
  final int precedence;

  const _MemberExpressionParser(this.precedence);

  @override
  TokenType get leading => TokenType.dot;

  @override
  bool eligible(ExpressionContext left, {bool ignoreComma: false}) => true;

  @override
  ExpressionContext parse(Parser parser, ExpressionContext left,
      {List<Comment> comments, bool ignoreComma: false}) {
    if (parser.peek()?.type != leading) return null;

    var dot = parser.consume(),
        lastSpan = dot.span,
        span = left.span.expand(lastSpan);
    var id = parser.parseSimpleIdentifier(comments: parser.parseComments());

    if (id == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing identifier after '.'.", lastSpan));
      return null;
    }

    span = span.expand(id.span);
    return new MemberExpressionContext(left, id, span, comments ?? []);
  }
}

class _TupleExpressionParser implements InfixParser<ExpressionContext> {
  final int precedence;

  const _TupleExpressionParser(this.precedence);

  @override
  bool eligible(ExpressionContext left, {bool ignoreComma: false}) =>
      !ignoreComma;

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

    return new TupleExpressionContext(
        [left.innermost, right.innermost], span, comments ?? []);
  }
}

// TODO: Support upgrade to assignment
class _BinaryExpressionParser implements InfixParser<ExpressionContext> {
  final TokenType leading;
  final int precedence;

  const _BinaryExpressionParser(this.leading, this.precedence);

  @override
  bool eligible(ExpressionContext left, {bool ignoreComma: false}) => true;

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
