import 'package:test/test.dart';
import '../util.dart';
import 'util.dart';

void main() {
  test('with "="', () {
    expect(parse('type Foo = Bar').typedefParser.parse(),
        isTypedef('Foo', isNamedType('Bar')));
  });

  test('without "="', () {
    expect(parse('type Foo Bar').typedefParser.parse(),
        isTypedef('Foo', isNamedType('Bar')));
  });

  test('sugared enum', () {
    expect(
        parse('enum Foo { foo, bar, baz = 45 }').typedefParser.parseSugaredEnum(),
        isTypedef(
            'Foo',
            isEnumType({
              'foo': 0,
              'bar': 1,
              'baz': 45,
            })));
  });
}
