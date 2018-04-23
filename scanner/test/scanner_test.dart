import 'package:scanner/scanner.dart';
import 'package:test/test.dart';
import 'util.dart';

void main() {
  group('misc.', () {
    test('comment',
        () => expect('// foo', scansOne(TokenType.comment, '// foo')));
  });

  group('symbols', () {
    test('arrow', () => expect('=>', scansOne(TokenType.arrow, '=>')));
    test('colon', () => expect(':', scansOne(TokenType.colon, ':')));
    test('comma', () => expect(',', scansOne(TokenType.comma, ',')));
    test('double_colon',
        () => expect('::', scansOne(TokenType.double_colon, '::')));
    test('lCurly', () => expect('{', scansOne(TokenType.lCurly, '{')));
    test('rCurly', () => expect('}', scansOne(TokenType.rCurly, '}')));
    test('lParen', () => expect('(', scansOne(TokenType.lParen, '(')));
    test('rParen', () => expect(')', scansOne(TokenType.rParen, ')')));
    test('lSq', () => expect('[', scansOne(TokenType.lSq, '[')));
    test('rSq', () => expect(']', scansOne(TokenType.rSq, ']')));
  });

  group('assignments', () {
    test('assign', () => expect('=', scansOne(TokenType.assign, '=')));
    test('assignAdd', () => expect('+=', scansOne(TokenType.assignAdd, '+=')));
    test('assignSub', () => expect('-=', scansOne(TokenType.assignSub, '-=')));
    test('assignTimes',
        () => expect('*=', scansOne(TokenType.assignTimes, '*=')));
    test('assignDiv', () => expect('/=', scansOne(TokenType.assignDiv, '/=')));
    test('assignMod', () => expect('%=', scansOne(TokenType.assignMod, '%=')));
    test('assignAnd', () => expect('&=', scansOne(TokenType.assignAnd, '&=')));
    test('assignOr', () => expect('|=', scansOne(TokenType.assignOr, '|=')));
    test('assignXor', () => expect('^=', scansOne(TokenType.assignXor, '^=')));
    test(
        'assignShl', () => expect('<<=', scansOne(TokenType.assignShl, '<<=')));
    test(
        'assignShr', () => expect('>>=', scansOne(TokenType.assignShr, '>>=')));
  });

  group('data', () {
    group('numbers', () {
      test('positive', () => expect('123', scansOne(TokenType.number, '123')));
      test('no negative',
          () => expect('-123', isNot(scansOne(TokenType.number, '-123'))));
    });

    test('single quoted string',
        () => expect("'foo'", scansOne(TokenType.string, "'foo'")));
    test('double quoted string',
        () => expect('"foo"', scansOne(TokenType.string, '"foo"')));
    test('identifier',
        () => expect('foo', scansOne(TokenType.identifier, 'foo')));
  });
}
