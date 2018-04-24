part of 'parser.dart';

class TypedefParser {
  final Parser parser;

  TypedefParser(this.parser);

  TypedefContext parse({List<Comment> comments}) {
    var span = parser.nextToken(TokenType.type)?.span, lastSpan = span;

    if (span == null) return null;

    var name = parser.parseSimpleIdentifier();

    if (name == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          'Missing identifier in typedef.', lastSpan));
      return null;
    }

    // Optionally parse `=` in typedef
    span = span.expand(lastSpan = name.span);
    var equals = parser.nextToken(TokenType.assign);

    if (equals != null) {
      span = span.expand(lastSpan = equals.span);
    }

    var type = parser.typeParser.parse(comments: parser.parseComments());

    if (type == null) {
      parser.errors.add(new BonoboError(
          BonoboErrorSeverity.error, 'Missing type in typedef.', lastSpan));
      return null;
    }

    return new TypedefContext(name, type, span, comments ?? []);
  }

  TypedefContext parseSugaredEnum({List<Comment> comments}) {
    // If we find enum Foo { bar, baz },
    // do a simple hack to swap the order of the tokens.
    var enumToken = parser.nextToken(TokenType.enum_);

    if (enumToken == null) return null;

    // Find a simple identifier.
    var id = parser.parseSimpleIdentifier(comments: parser.parseComments());

    if (id == null) {
      return null;
    }

    // So, we want to create type Foo enum { ... }
    // We can manufacture a 'type' and ID token,
    // and shoot them to the top of the token queue.
    //
    // Then, we just insert the 'enum' right after.
    var typeToken = new Token(TokenType.type, id.span, null),
        idToken = new Token(TokenType.identifier, id.span, null);
    parser.scanner.tokens.insertAll(parser._index + 1, [typeToken, idToken, enumToken]);
    return parse(comments: comments);
  }
}
