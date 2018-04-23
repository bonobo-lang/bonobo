import 'package:test/test.dart';
import '../util.dart';

void main() {
  test('number literal', () {
    expect('1', isNumberLiteral(1));
    expect('1.0', isNumberLiteral(1.0));
  });

  test('hex literal', () {
    expect('0xa', isNumberLiteral(0xa));
    expect('0xAF1', isNumberLiteral(0xAF1));
    expect('0xAFc', isNumberLiteral(0xAFc));
  });

  test('hex literal double value throws', () {
    var literal = parse('0x12').expressionParser.parseNumberLiteral();
    expect(() => literal.doubleValue, throwsArgumentError);
  });
}

Matcher isNumberLiteral(num value) {
  return predicate((x) {
    var literal = parse(x.toString()).expressionParser.parseNumberLiteral();
    if (literal == null) return false;
    if (value is int)
      return literal.intValue == value;
    else
      return literal.doubleValue == value;
  });
}
