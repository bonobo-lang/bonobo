import 'package:bonobo/parser/parser.dart';
import 'package:bonobo/scanner/scanner.dart';

Parser parse(String source) {
  var scanner = new Scanner(source)..scan();
  return new Parser(scanner);
}
