import 'package:test/test.dart';
import '../util.dart';

void main() {
  test('full syntax', () {
    expect(
        parse('enum { foo, bar, baz = 45 }').typeParser.parse(),
        isEnumType({
          'foo': 0,
          'bar': 1,
          'baz': 45,
        }));
  });
}
