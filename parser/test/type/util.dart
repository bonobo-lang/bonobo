import 'package:ast/ast.dart';
import 'package:matcher/matcher.dart';

Matcher isIdentifierType(String name) => predicate(
    (x) => x is SimpleIdentifierTypeContext && x.identifier.name == name);
