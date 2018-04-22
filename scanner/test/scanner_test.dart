import 'package:scanner/scanner.dart';
import 'package:test/test.dart';
import 'util.dart';

void main() {
  test('identifier', () => expect('foo', scansOne(TokenType.identifier, 'foo')));
}
