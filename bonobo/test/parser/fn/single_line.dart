import 'package:bonobo/parser/parser.dart';
import 'package:bonobo/scanner/scanner.dart';
import 'package:test/test.dart';
import 'package:bonobo/ast/ast.dart';

void main() {
  group('fn', () {
    group('SingleLine', () {
      test('No exp', () {
        var scanner = new Scanner("fn pub main => print('Hello, world!')",
            sourceUrl: 'main.bnb');
        scanner.scan();

        var parser = new Parser(scanner);
        CompilationUnitContext unit = parser.parseCompilationUnit();
        expect(parser.errors.length, 0);
        expect(unit.functions.length, 1);
        expect(unit.toString(), "fn pub main => print('Hello, world!')\n\n");
      });
    });

    group('SingleLine', () {
      test('exp', () {
        var scanner =
            new Scanner("fn pub main => 5 + 5", sourceUrl: 'main.bnb');
        scanner.scan();

        var parser = new Parser(scanner);
        CompilationUnitContext unit = parser.parseCompilationUnit();
        expect(parser.errors.length, 0);
        expect(unit.functions.length, 1);
        expect(unit.toString(), "fn pub main => print('Hello, world!')\n\n");
      });
    });
  });
}
