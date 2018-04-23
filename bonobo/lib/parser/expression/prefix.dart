part of '../parser.dart';

const List<PrefixParser<ExpressionContext>> prefixParsers = const [
  const _IdentifierParser(),
  const _StringLiteralParser(),
  const _NumberLiteralParser(),
  const _ParenthesesParser(),
];

/// Standalone expressions/types.
abstract class PrefixParser<T> {
  T parse(Parser parser, {List<Comment> comments, bool ignoreComma: false});
}

class _IdentifierParser implements PrefixParser<ExpressionContext> {
  const _IdentifierParser();

  @override
  ExpressionContext parse(Parser parser,
      {List<Comment> comments, bool ignoreComma: false}) {
    var id = parser.nextToken(TokenType.identifier);

    if (id == null) return null;

    var identifiers = <Token>[id];
    var span = id.span;

    while (parser.peek()?.type == TokenType.double_colon) {
      var doubleColon = parser.nextToken(TokenType.double_colon);
      span = span.expand(doubleColon.span);

      if (parser.peek()?.type == TokenType.identifier) {
        id = parser.consume();
      } else {
        id = null;
      }

      if (id == null) {
        if (span == null) return null;
        parser.errors.add(new BonoboError(
            BonoboErrorSeverity.error, "Missing identifier after '::'.", span));
        return null;
      } else {
        span = span.expand(id.span);
        identifiers.add(id);
      }
    }

    if (identifiers.length == 1) {
      return new SimpleIdentifierContext(span, comments ?? []);
    }

    var parts = identifiers
        .take(identifiers.length - 1)
        .map((t) => new SimpleIdentifierContext(t.span, []))
        .toList();
    return new NamespacedIdentifierContext(
        parts,
        new SimpleIdentifierContext(identifiers.last.span, []),
        span,
        comments ?? []);
  }
}

class _StringLiteralParser implements PrefixParser<ExpressionContext> {
  const _StringLiteralParser();

  @override
  ExpressionContext parse(Parser parser,
      {List<Comment> comments, bool ignoreComma: false}) {
    var string = parser.nextToken(TokenType.string);
    return string == null
        ? null
        : new StringLiteralContext(string.span, comments ?? []);
  }
}

class _NumberLiteralParser implements PrefixParser<ExpressionContext> {
  const _NumberLiteralParser();

  @override
  ExpressionContext parse(Parser parser,
      {List<Comment> comments, bool ignoreComma: false}) {
    if (parser.peek()?.type == TokenType.number)
      return new NumberLiteralContext(parser.consume().span, comments ?? []);
    return _parseHex(parser, comments);
  }

  NumberLiteralContext _parseHex(Parser parser, List<Comment> comments) {
    if (parser.peek()?.type == TokenType.hex) {
      return new HexLiteralContext(parser.consume().span, comments ?? []);
    }
    return null;
  }
}

class _ParenthesesParser implements PrefixParser<ExpressionContext> {
  const _ParenthesesParser();

  @override
  ExpressionContext parse(Parser parser,
      {List<Comment> comments, bool ignoreComma: false}) {
    var lParen = parser.nextToken(TokenType.lParen),
        span = lParen?.span,
        lastSpan = span;
    if (lParen == null) return null;

    var expression = parser.expressionParser
        .parse(0, comments: parser.parseComments(), ignoreComma: false);

    if (expression == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after '('.", lastSpan));
      return null;
    }

    var rParen = parser.nextToken(TokenType.rParen)?.span;
    span = span.expand(lastSpan = expression.span);

    if (rParen == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing ')' after expression.", lastSpan));
      return null;
    }

    return new ParenthesizedExpressionContext(
        expression, span.expand(rParen), comments ?? []);
  }
}
