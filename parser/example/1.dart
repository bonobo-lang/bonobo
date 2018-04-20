import 'package:scanner/scanner.dart';
import 'package:parser/parser.dart';
import 'package:ast/ast.dart';

main() async {
  var scanner = new Scanner("fn pub main => 5 + 5",
      sourceUrl: 'main.bnb');
  scanner.scan();
  // print(scanner.errors);
  // print(scanner.tokens.join('\n\n'));

  var parser = new BonoboParseState(scanner);
  UnitContext unit = parser.parse();
  print(parser.errors);
  print(unit);
}
