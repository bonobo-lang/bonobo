import 'package:ast/ast.dart';
import 'package:test/test.dart';
import '../util.dart';
import 'util.dart';

void main() {
  test('parse normal field', () {
    var field = parse('foo: Bar').typeParser.parseStructField();
    expect(field, isNotNull);
    expect(field.name.name, 'foo');
    expect(field.type, const isInstanceOf<SimpleIdentifierTypeContext>());
    expect((field.type as SimpleIdentifierTypeContext).identifier.name, 'Bar');
  });

  test('parse function sugar field', () {
    var field = parse('fn foo(Bar, Baz): Quux').typeParser.parseStructField();
    expect(field, isNotNull);
    expect(field.name.name, 'foo');
    expect(field.type, const isInstanceOf<FunctionTypeContext>());
    var fnType = field.type as FunctionTypeContext;
    expect(fnType.parameters, hasLength(2));
    expect(fnType.parameters[0], isIdentifierType('Bar'));
    expect(fnType.parameters[1], isIdentifierType('Baz'));
    expect(fnType.returnType, isIdentifierType('Quux'));
  });

  test('struct type', () {
    var parser = parse('{ foo: Bar, baz: Quux fn yes(): No }');
    var structType = parser.typeParser.parseStructType();
    expect(structType, isNotNull);
    expect(structType.fields, hasLength(3));
    expect(structType.fields[0].name.name, 'foo');
    expect(structType.fields[0].type, isIdentifierType('Bar'));
    expect(structType.fields[1].name.name, 'baz');
    expect(structType.fields[1].type, isIdentifierType('Quux'));
    expect(structType.fields[2].name.name, 'yes');
    expect(
        structType.fields[2].type, const isInstanceOf<FunctionTypeContext>());
    var fnType = structType.fields[2].type as FunctionTypeContext;
    expect(fnType.parameters, hasLength(0));
    expect(fnType.returnType, isIdentifierType('No'));
  });
}
