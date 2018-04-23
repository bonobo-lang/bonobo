import 'package:bonobo/parser/parser.dart';
import 'package:bonobo/scanner/scanner.dart';
import 'package:test/test.dart';
import 'package:bonobo/ast/ast.dart';

void main() {
  test('expression body', () {
    expect("fn main => 5 + 5", isLambdaFunctionBody());
    expect("fn main => 'Hello, world!'", isLambdaFunctionBody());
  });
}

Matcher isLambdaFunctionBody() {
  return predicate((x) {
    var scanner = new Scanner(x.toString())..scan();
    var parser = new Parser(scanner);
    CompilationUnitContext unit = parser.parseCompilationUnit();

    if (parser.errors.isNotEmpty) {
      for (var error in parser.errors) {
        print(error.message);
        print(error.span.highlight());
      }

      return false;
    }

    if (unit.functions.isEmpty) return false;

    if (!equals('main').matches(unit.functions[0].name.name, {})) return false;

    if (!const isInstanceOf<ExpressionFunctionBodyContext>()
        .matches(unit.functions[0].body, {})) return false;

    return true;
  });
}
