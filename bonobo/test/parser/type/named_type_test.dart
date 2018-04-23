import 'package:test/test.dart';
import '../util.dart';
import 'util.dart';

void main() {
  test('simple identifier', () {
    expect(parse('foo').typeParser.parse(), isNamedType('foo'));
  });

  test('namespaced identifier', () {
    expect(parse('foo::bar::baz').typeParser.parse(),
        isNamedType('foo::bar::baz', namespaced: true));
  });
}
