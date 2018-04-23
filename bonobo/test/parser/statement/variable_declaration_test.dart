import 'package:bonobo/ast/ast.dart';
import 'package:bonobo/scanner/token.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';
import '../type/util.dart';
import '../util.dart';

void main() {
  VariableDeclarationContext parseVariableDeclaration(String text) =>
      parse(text)
          .statementParser
          .variableDeclarationParser
          .parseVariableDeclaration();

  VariableDeclarationStatementContext parseVariableDeclarationStatement(
          String text) =>
      parse(text).statementParser.variableDeclarationParser.parse();

  Matcher isVariableDeclaration(
          {Matcher name, Matcher type, Matcher expression}) =>
      predicate((x) =>
          x is VariableDeclarationContext &&
          (name == null || name.matches(x.name, {})) &&
          (type == null || type.matches(x.type, {})) &&
          (expression == null || expression.matches(x.expression, {})));

  Matcher hasMutability(TokenType type,
          bool Function(VariableDeclarationStatementContext) p) =>
      predicate((x) =>
          x is VariableDeclarationStatementContext &&
          x.mutability.type == type &&
          p(x));

  test('single declaration', () {
    var stmt = parseVariableDeclarationStatement('var foo = bar');
    expect(stmt.declarations, hasLength(1));
    expect(stmt.declarations[0], isVariableDeclaration(
      name: isIdentifier('foo'),
      type: isNull,
      expression: isIdentifier('bar'),
    ));
  });

  test('multiple declarations', () {
    var stmt = parseVariableDeclarationStatement('var foo = bar, baz: Baz = quux, yes = no');
    expect(stmt.declarations, hasLength(3));
    expect(stmt.declarations[0], isVariableDeclaration(
      name: isIdentifier('foo'),
      type: isNull,
      expression: isIdentifier('bar'),
    ));
    expect(stmt.declarations[1], isVariableDeclaration(
      name: isIdentifier('baz'),
      type: isNamedType('Baz'),
      expression: isIdentifier('quux'),
    ));
    expect(stmt.declarations[2], isVariableDeclaration(
      name: isIdentifier('yes'),
      type: isNull,
      expression: isIdentifier('no'),
    ));
  });

  test('mutability', () {
    Map<String, Tuple2<TokenType, bool Function(VariableDeclarationStatementContext)>> testCases = {
      'var': new Tuple2(TokenType.var_, (x) => !x.isImmutable),
      'final': new Tuple2(TokenType.final_, (x) => x.isImmutable && x.isFinal),
      'const': new Tuple2(TokenType.const_, (x) => x.isImmutable && x.isConst),
    };

    testCases.forEach((mut, tuple) {
      var stmt = parseVariableDeclarationStatement('$mut foo = bar');
      expect(stmt, hasMutability(tuple.item1, tuple.item2));
    });
  });

  group('variable declaration', () {
    test('no type annotation', () {
      var decl = parseVariableDeclaration('foo = bar');
      expect(decl, isNotNull);
      expect(decl.type, isNull);
      expect(decl.name.name, 'foo');
      expect(decl.expression, isIdentifier('bar'));
    });

    test('type annotation', () {
      var decl = parseVariableDeclaration('foo: Bar = bar');
      expect(decl, isNotNull);
      expect(decl.type, isNamedType('Bar'));
      expect(decl.name.name, 'foo');
      expect(decl.expression, isIdentifier('bar'));
    });

    test('broken type annotation', () {
      var decl = parseVariableDeclaration('foo: = bar');
      expect(decl, isNull);
    });
  });
}
