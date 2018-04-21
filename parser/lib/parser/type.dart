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
      NamespacedIdentifierContext tn = name as NamespacedIdentifierContext;
      namespaces = tn.namespaces;
      name = tn.symbol;
    }

    // TODO parse generics

    return new TypeContext(name.span.expand(lastSpan), [], name,
        namespaces: namespaces);
  }
}
