part of 'parser.dart';

class TypeParser {
  final Parser state;

  TypeParser(this.state);

  // When calling `parse` from methods within this class,
  // Be sure to forward the value of `ignoreComma`. Otherwise,
  // there can be ambiguity when a comma appears in a variable declaration statement.
  TypeContext parse({List<Comment> comments, bool ignoreComma: false}) {
    // TODO parse special List syntax
    // TODO parse special Map syntax

    TypeContext type = parseSingleType(comments: comments);

    if (type == null) return null;

    while (!state.done) {
      switch (state.peek()?.type) {
        case TokenType.comma:
          if (ignoreComma == true) break;
          // Consume the token, then read in the other type in this tuple.
          var comma = state.consume();
          var nextType = parse(comments: state.parseComments());
          var span = type.span.expand(nextType.span);
          nextType = nextType.innermost;

          if (nextType == null) {
            state.errors.add(new BonoboError(BonoboErrorSeverity.error,
                "Missing type after ','.", comma.span));
            return null;
          }

          // If the other type is a tuple, combine the two.
          if (nextType is TupleTypeContext) {
            type = new TupleTypeContext([type]..addAll(nextType.items), span,
                []..addAll(comments)..addAll(nextType.comments));
          }

          // Otherwise, create a new one.
          else {
            type = new TupleTypeContext([type, nextType], span, comments);
          }
          break;
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
      // If we didn't find an identifier type,
      // try for a struct or parenthesized type
      return parseParenthesizedType(comments: comments);
    }

    if (name is NamespacedIdentifierContext) {
      return new NamespacedIdentifierTypeContext(name, comments ?? []);
    } else {
      return new SimpleIdentifierTypeContext(name, comments ?? []);
    }
  }

  StructTypeContext parseStructType({List<Comment> comments}) {

  }

  StructFieldContext parseStructField({List<Comment> comments}) {
    var name = state.parseSimpleIdentifier(), span = name?.span, lastSpan = span;

    if (name == null)
      return null;

    var colon = state.nextToken(TokenType.colon);

    if (colon == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing ':' after '${name.name}'.", lastSpan));
      return null;
    }

    span = span.expand(lastSpan = colon.span);

    var type = parse(comments: state.parseComments());

    if (type == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing type after ':'.", colon.span));
      return null;
    }

    span = span.expand(type.span);
    return new StructFieldContext(name, type, span, comments);
  }

  ParenthesizedTypeContext parseParenthesizedType({List<Comment> comments}) {
    var span = state.nextToken(TokenType.lParen)?.span, lastSpan = span;

    if (span == null) return null;

    var inner = parse(comments: state.parseComments(), ignoreComma: false);

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

    return new ParenthesizedTypeContext(inner, span, comments ?? []);
  }
}
