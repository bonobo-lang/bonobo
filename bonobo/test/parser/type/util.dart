import 'package:bonobo/ast/ast.dart';
import 'package:matcher/matcher.dart';

Matcher isNamedType(String name, {bool namespaced: false}) => predicate((x) =>
    x is NamedTypeContext &&
    x.identifier.name == name &&
    (x.identifier is NamespacedIdentifierContext) == namespaced);
