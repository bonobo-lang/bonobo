part of 'parser.dart';

class TypedefParser {
  final Parser state;

  TypedefParser(this.state);

  TypedefContext parse({List<Comment> comments}) {
    var span = state.nextToken(TokenType.type)?.span, lastSpan = span;

    if (span == null) return null;

    var name = state.parseSimpleIdentifier();

    if (name == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          'Missing identifier in typedef.', lastSpan));
      return null;
    }

    // Optionally parse `=` in typedef
    span = span.expand(lastSpan = name.span);
    var equals = state.nextToken(TokenType.assign);

    if (equals != null) {
      span = span.expand(lastSpan = equals.span);
    }
    // TODO: Pass these to type parser
    var type = state.typeParser.parse(comments: state.parseComments());

    if (type == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error, 'Missing type in typedef.', lastSpan));
      return null;
    }

    return new TypedefContext(name, type, span, comments);
  }
}
