import 'package:bonobo/ast/ast.dart';
import 'package:test/test.dart';
import '../util.dart';

void main() {
  test('inclusive no step', () {
    var expr = parse('1 .. 5').expressionParser.parse(0);
    expect(expr, const isInstanceOf<RangeLiteralContext>());
    expect(expr.isConstant, true);
    expect(expr.constantValue, [1, 2, 3, 4, 5]);
  });

  test('exclusive no step', () {
    var expr = parse('1 ... 5').expressionParser.parse(0);
    expect(expr, const isInstanceOf<RangeLiteralContext>());
    expect(expr.isConstant, true);
    expect(expr.constantValue, [1, 2, 3, 4]);
  });

  test('inclusive with step', () {
    var expr = parse('0 .. 10, 2').expressionParser.parse(0);
    expect(expr, const isInstanceOf<RangeLiteralContext>());
    expect(expr.isConstant, true);
    expect(expr.constantValue, [0, 2, 4, 6, 8, 10]);
  });

  test('exclusive with step', () {
    var expr = parse('0 ... 10, 2').expressionParser.parse(0);
    expect(expr, const isInstanceOf<RangeLiteralContext>());
    expect(expr.isConstant, true);
    expect(expr.constantValue, [0, 2, 4, 6, 8]);
  });
}