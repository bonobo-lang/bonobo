part of 'parser.dart';

class ClassParser {
  final BonoboParseState state;

  ClassParser(this.state);

  parse() {
    FileSpan startSpan = state.peek().span;

    if (state.nextToken(TokenType.fn) == null) return null;

    bool isPub = state.nextToken(TokenType.pub) != null;

    // TODO final modifier

    SimpleIdentifierContext name = state.nextSimpleId();

    if (name == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Expected class name.",
          state.peek().span /* TODO What if there is no token? */));
      return null;
    }

    // TODO parse implements clause

    // TODO parse mixes clause

    // TODO parse class body

    // TODO return ClassDeclContext
  }
}