import 'package:bonobo/ast/ast.dart';
import 'package:matcher/matcher.dart';

Matcher isNamedType(String name) => predicate(
    (x) => x is NamedTypeContext && x.identifier.name == name);
