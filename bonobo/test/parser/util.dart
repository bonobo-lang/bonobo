import 'package:bonobo/parser/parser.dart';
import 'package:bonobo/scanner/scanner.dart';
import 'package:test/test.dart';
import 'package:bonobo/ast/ast.dart';

Parser parse(String source) {
  var scanner = new Scanner(source)..scan();
  return new Parser(scanner);
}
