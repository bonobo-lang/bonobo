part of 'parser.dart';

class TypedefParser {
  final Parser state;

  TypedefParser(this.state);

  TypedefContext parse({List<Comment> comments}) {
    var span = state.nextToken(TokenType.type)?.span, lastSpan = span;

    if (span == null) return null;

    var name = state.parseSimpleIdentifier();

    if (name == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error, 'Missing identifier in typedef.', lastSpan));
      return null;
    }

    // Optionally parse `=` in typedef
    var colonEquals = state.nextToken(TokenType.equals);

    if (colonEquals != null) {
      span = span.expand(lastSpan = colonEquals.span);
    }

    var comments = state.parseComments();

    // TODO: Pass these to type parser
    var type = state.typeParser.parse();

    if (type == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error, 'Missing type in typedef.', lastSpan));
      return null;
    }

    return new TypedefContext(name, type, span, comments);
  }
}
