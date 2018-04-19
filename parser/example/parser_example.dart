import 'package:scanner/scanner.dart';
import 'package:parser/parser.dart';
import 'package:ast/ast.dart';

main() async {
  Source src = await Source.fromPath('../example/hello/main.bnb');
  var scanner = new Scanner(src.contents, sourceUrl: src.uri);
  scanner.scan();
  // print(scanner.errors);
  // print(scanner.tokens.join('\n\n'));

  UnitContext unit = parseUnit(scanner);
  print(unit.functions);
}
