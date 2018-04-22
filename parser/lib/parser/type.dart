part of 'parser.dart';

class TypeParser {
  final Parser state;

  TypeParser(this.state);

  TypeContext parse({List<Comment> comments}) {
    // TODO parse special Tuple syntax
    // TODO parse special List syntax
    // TODO parse special Map syntax

    TypeContext type = parseSingleType(comments: comments);

    if (type == null) return null;

    while (!state.done) {
      switch (state.peek()?.type) {
        default:
          break;
      }
    }

    return type;
    // TODO parse generics
  }

  TypeContext parseSingleType({List<Comment> comments}) {
    IdentifierContext name = state.parseIdentifier();

    if (name == null) {
      // If we didn't find an identifier type, try for a parenthesized type
      return parseParenthesizedType(comments: comments);
    }

    if (name is NamespacedIdentifierContext) {
      return new NamespacedIdentifierTypeContext(name, comments ?? []);
    } else {
      return new SimpleIdentifierTypeContext(name, comments ?? []);
    }
  }

  _ParenthesizedType parseParenthesizedType({List<Comment> comments}) {
    var span = state.nextToken(TokenType.lParen)?.span, lastSpan = span;

    if (span == null) return null;

    var inner = parse(comments: state.parseComments());

    if (inner == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing type after '('.", lastSpan));
      return null;
    }

    span = span.expand(lastSpan = inner.span);
    var rParen = state.nextToken(TokenType.rParen)?.span;

    if (rParen == null) {
      state.errors.add(
          new BonoboError(BonoboErrorSeverity.error, "Missing ')'.", lastSpan));
      return null;
    }

    return new _ParenthesizedType(inner, span, comments ?? []);
  }
}

class _ParenthesizedType extends TypeContext {
  final TypeContext inner;

  _ParenthesizedType(this.inner, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => inner.accept(visitor);
}
