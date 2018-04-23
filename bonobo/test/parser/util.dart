import 'package:parser/parser.dart';
import 'package:scanner/scanner.dart';
import 'package:test/test.dart';
import 'package:ast/ast.dart';

Parser parse(String source) {
  var scanner = new Scanner(source)..scan();
  return new Parser(scanner);
}
