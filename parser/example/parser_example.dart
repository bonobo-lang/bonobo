import 'package:file/local.dart';
import 'package:scanner/scanner.dart';
import 'package:parser/parser.dart';
import 'package:ast/ast.dart';

main() async {
  Source src = await Source.fromPath(
      const LocalFileSystem(), '../example/enum/main.bnb');
  // Source src = await Source.fromPath(
  //    const LocalFileSystem(), '../example/math/simple.bnb');
  var scanner = new Scanner(src.contents, sourceUrl: src.uri);
  scanner.scan();
  // print(scanner.errors);
  // print(scanner.tokens.join('\n\n'));

  var parser = new Parser(scanner);
  CompilationUnitContext unit = parser.parseCompilationUnit();
  print(parser.errors);
  print(unit);
}
