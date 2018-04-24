import 'package:bonobo/ast/ast.dart';
import 'package:test/test.dart';
import '../util.dart';

void main() {
  test('no arguments', () {
    var expr = parse('foo()').expressionParser.parse(0);
    expect(expr, const isInstanceOf<CallExpressionContext>());
    var call = expr as CallExpressionContext;
    expect(call.target, isIdentifier('foo'));
    expect(call.arguments.expressions, isEmpty);
  });

  test('single tuple argument', () {
    var expr = parse('foo((bar, baz))').expressionParser.parse(0);
    expect(expr, const isInstanceOf<CallExpressionContext>());
    var call = expr as CallExpressionContext;
    expect(call.target, isIdentifier('foo'));
    expect(call.arguments.expressions, hasLength(1));
    expect(call.arguments.expressions[0].innermost, const isInstanceOf<TupleExpressionContext>());
    var tup = call.arguments.expressions[0].innermost as TupleExpressionContext;
    expect(tup.expressions, hasLength(2));
    expect(tup.expressions[0], isIdentifier('bar'));
    expect(tup.expressions[1], isIdentifier('baz'));
  });

  test('multiple arguments', () {
    var expr = parse('foo(bar, baz)').expressionParser.parse(0);
    expect(expr, const isInstanceOf<CallExpressionContext>());
    var call = expr as CallExpressionContext;
    expect(call.target, isIdentifier('foo'));
    expect(call.arguments.expressions, hasLength(2));
    expect(call.arguments.expressions[0], isIdentifier('bar'));
    expect(call.arguments.expressions[1], isIdentifier('baz'));
  });
}