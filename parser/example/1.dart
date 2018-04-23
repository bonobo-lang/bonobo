<<<<<<< HEAD
import 'package:scanner/scanner.dart';
import 'package:parser/parser.dart';
import 'package:ast/ast.dart';

main() async {
  // var scanner = new Scanner("fn main => 5 + 6 * 7 + 8", sourceUrl: 'main.bnb');
  var scanner =
      new Scanner("fn main => 5 + !6 * 7 + ~8", sourceUrl: 'main.bnb');
  // var scanner = new Scanner("fn hide main => print('Hello, world!')",
  //    sourceUrl: 'main.bnb');
  scanner.scan();
  // print(scanner.errors);
  // print(scanner.tokens.join('\n\n'));

  var parser = new Parser(scanner);
  CompilationUnitContext unit = parser.parseCompilationUnit();
  print(parser.errors);
  print(unit);
}
=======
import 'package:scanner/scanner.dart';
import 'package:parser/parser.dart';
import 'package:ast/ast.dart';

main() async {
  var scanner = new Scanner("fn main => 5 + 6 * 7 + 8", sourceUrl: 'main.bnb');
  // var scanner =
  //    new Scanner("fn main => 5 + !6 * 7 + ~8", sourceUrl: 'main.bnb');
  // var scanner = new Scanner("fn hide main => print('Hello, world!')",
  //    sourceUrl: 'main.bnb');
  scanner.scan();
  // print(scanner.errors);
  // print(scanner.tokens.join('\n\n'));

  var parser = new Parser(scanner);
  CompilationUnitContext unit = parser.parseCompilationUnit();
  print(parser.errors);
  print(unit);
}
>>>>>>> a74882f7d754f12d199f21700d9b663870b2711d
