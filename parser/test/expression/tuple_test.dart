import 'package:ast/ast.dart';
import 'package:test/test.dart';
import '../util.dart';

void main() {
  test('single item is not a tuple', () {
    var exp = parse('(1234)').expressionParser.parse();
    expect(exp, isNot(const isInstanceOf<TupleExpressionContext>()));
  });

  test('two items', () {
    var exp = parse('(1234, 4321)').expressionParser.parse();
    expect(exp, const isInstanceOf<TupleExpressionContext>());
    var tuple = exp as TupleExpressionContext;
    expect(tuple.expressions.length, 2);
    expect(tuple.expressions,
        everyElement(const isInstanceOf<NumberLiteralContext>()));
  });

  test('three items', () {
    var exp = parse('(1234, 4321, 1234)').expressionParser.parse();
    expect(exp, const isInstanceOf<TupleExpressionContext>());
    var tuple = exp as TupleExpressionContext;
    expect(tuple.expressions.length, 3);
    expect(tuple.expressions,
        everyElement(const isInstanceOf<NumberLiteralContext>()));
  });

  test('tuple within tuple', () {
    var exp = parse('(1234, 4321, (1234, 4321))').expressionParser.parse();
    expect(exp, const isInstanceOf<TupleExpressionContext>());
    var tuple = exp as TupleExpressionContext;
    expect(tuple.expressions.length, 3);
    expect(tuple.expressions[0], const isInstanceOf<NumberLiteralContext>());
    expect(tuple.expressions[1], const isInstanceOf<NumberLiteralContext>());
    expect(tuple.expressions[2], const isInstanceOf<TupleExpressionContext>());
  });

  test('tuple of tuples', () {
    var exp = parse('((1234, 4321), (1234, 4321))').expressionParser.parse();
    expect(exp, const isInstanceOf<TupleExpressionContext>());
    var tuple = exp as TupleExpressionContext;
    expect(tuple.expressions.length, 2);
    expect(tuple.expressions,
        everyElement(const isInstanceOf<TupleExpressionContext>()));
  });
}
