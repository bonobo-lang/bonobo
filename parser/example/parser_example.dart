import 'package:scanner/scanner.dart';
import 'package:parser/parser.dart';
import 'package:ast/ast.dart';

main() async {
  Source src = await Source.fromPath('../example/types/main.bnb');
  var scanner = new Scanner(src.contents, sourceUrl: src.uri);
  scanner.scan();
  // print(scanner.errors);
  // print(scanner.tokens.join('\n\n'));

  var parser = new BonoboParseState(scanner);
  UnitContext unit = parser.parse();
  print(parser.errors);
  print(unit);
}
