part of 'parser.dart';

class TypeParser {
  final BonoboParseState state;

  TypeParser(this.state);

  TypeContext parse() {
    IdentifierContext name = state.nextId();
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
