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

Matcher isTypedef(String name, Matcher type) =>
    predicate((x) => x is TypedefContext && type.matches(x.type, {}));

Matcher isEnumType(Map<String, int> values) => predicate((x) =>
    x is EnumTypeContext &&
    values.keys.every((name) {
      var value =
          x.values.firstWhere((v) => v.name.name == name, orElse: () => null);
      if (value == null) return false;
      return (value.index?.intValue ?? values.keys.toList().indexOf(name)) ==
          values[name];
    }));
