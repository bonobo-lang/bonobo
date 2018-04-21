part of 'parser.dart';

class TypeParser {
  final Parser state;

  TypeParser(this.state);

  TypeContext parse() {
    // TODO parse special Tuple syntax
    // TODO parse special List syntax
    // TODO parse special Map syntax

    IdentifierContext name = state.parseIdentifier();
    FileSpan lastSpan = name.span;
    if (name == null) return null;

    var namespaces = <IdentifierContext>[];

    if (name is NamespacedIdentifierContext) {
      return new NamespacedIdentifierTypeContext(name, []);
    } else {
      return new SimpleIdentifierTypeContext(name, []);
    }

    // TODO parse generics
  }
}
