import 'package:bonobo/ast/ast.dart';
import 'package:test/test.dart';
import '../util.dart';

void main() {
  test('member expression', () {
    var expr = parse('foo.bar').expressionParser.parse(0);
    expect(expr, const isInstanceOf<MemberExpressionContext>());
    var mExpr = expr as MemberExpressionContext;
    expect(mExpr.target, isIdentifier('foo'));
    expect(mExpr.identifier, isIdentifier('bar'));
  });

  test('higher precedence than tuple', () {
    var expr = parse('foo, bar.baz').expressionParser.parse(0);
    expect(expr, const isInstanceOf<TupleExpressionContext>());
    var tuple = expr as TupleExpressionContext;
    expect(tuple.expressions[0], isIdentifier('foo'));
    expect(tuple.expressions[1], const isInstanceOf<MemberExpressionContext>());
    var mExpr = tuple.expressions[1] as MemberExpressionContext;
    expect(mExpr.target, isIdentifier('bar'));
    expect(mExpr.identifier, isIdentifier('baz'));
  });
}