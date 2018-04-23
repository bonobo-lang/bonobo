import 'package:bonobo/ast/ast.dart';
import 'package:test/test.dart';
import '../util.dart';

void main() {
  VariableDeclarationContext parseVariableDeclaration(String text) =>
      parse(text)
          .statementParser
          .variableDeclarationParser
          .parseVariableDeclaration();

  group('variable declaration', () {
    test('no type annotation', () {
      var decl = parseVariableDeclaration('foo = bar');
      expect(decl, isNotNull);
    });

    test('type annotation', () {});

    test('broken type annotation', () {});
  });
}
