part of 'parser.dart';

class IdentifierParser {
  final Parser state;

  IdentifierParser(this.state);

  IdentifierContext parse() {
    var id = state.nextToken(TokenType.identifier);

    if (id == null) return null;

    var identifiers = <Token>[id];
    var span = id.span;

    while (state.peek()?.type == TokenType.double_colon) {
      var doubleColon = state.nextToken(TokenType.double_colon);
      span = span.expand(doubleColon.span);

      if (state.peek()?.type == TokenType.identifier) {
        id = state.consume();
      } else {
        id = null;
      }

      if (id == null) {
        if (span == null) return null;
        state.errors.add(new BonoboError(
            BonoboErrorSeverity.error, "Missing identifier after '::'.", span));
        return null;
      } else {
        span = span.expand(id.span);
        identifiers.add(id);
      }
    }

    if (identifiers.length == 1) {
      return new SimpleIdentifierContext(span, []);
    }

    var parts = identifiers
        .take(identifiers.length - 1)
        .map((t) => new SimpleIdentifierContext(t.span, []))
        .toList();
    return new NamespacedIdentifierContext(parts,
        new SimpleIdentifierContext(identifiers.last.span, []), span, []);
  }
}
