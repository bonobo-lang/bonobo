import 'package:bonobo/ast/ast.dart';
import 'package:bonobo/parser/parser.dart';
import 'package:bonobo/scanner/scanner.dart';
import 'package:matcher/matcher.dart';

Parser parse(String source) {
  var scanner = new Scanner(source)..scan();
  return new Parser(scanner);
}

Matcher isIdentifier(String name,
        {bool namespaced: false, List<String> namespaces}) =>
    predicate((x) =>
        x is IdentifierContext &&
        (x.name == name) &&
        ((x is NamespacedIdentifierContext) == namespaced) &&
        (namespaces == null ||
            (x is NamespacedIdentifierContext &&
                equals(namespaces)
                    .matches(x.namespaces.map((n) => n.name), {}))));
