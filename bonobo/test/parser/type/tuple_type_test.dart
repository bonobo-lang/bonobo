import 'package:bonobo/ast/ast.dart';
import 'package:test/test.dart';
import '../util.dart';
import 'util.dart';

void main() {
  test('single item is not a tuple', () {
    var exp = parse('(Foo)').typeParser.parse();
    expect(exp, isNot(const isInstanceOf<TupleTypeContext>()));
  });

  test('two items', () {
    var exp = parse('(Foo, Bar)').typeParser.parse().innermost;
    expect(exp, const isInstanceOf<TupleTypeContext>());
    var tuple = exp as TupleTypeContext;
    expect(tuple.items.length, 2);
    expect(tuple.items[0], isNamedType('Foo'));
    expect(tuple.items[1], isNamedType('Bar'));
  });

  test('three items', () {
    var exp = parse('(Foo, Bar, Foo)').typeParser.parse().innermost;
    expect(exp, const isInstanceOf<TupleTypeContext>());
    var tuple = exp as TupleTypeContext;
    expect(tuple.items.length, 3);
    expect(tuple.items[0], isNamedType('Foo'));
    expect(tuple.items[1], isNamedType('Bar'));
  });

  test('tuple within tuple', () {
    var exp = parse('(Foo, Bar, (Foo, Bar))').typeParser.parse().innermost;
    expect(exp, const isInstanceOf<TupleTypeContext>());
    var tuple = exp as TupleTypeContext;
    expect(tuple.items.length, 3);
    expect(tuple.items[0], isNamedType('Foo'));
    expect(tuple.items[1], isNamedType('Bar'));
    expect(tuple.items[2], const isInstanceOf<TupleTypeContext>());
    var tup = tuple.items[2] as TupleTypeContext;
    expect(tup.items[0], isNamedType('Foo'));
    expect(tup.items[1], isNamedType('Bar'));
  });

  test('tuple of tuples', () {
    var exp = parse('((Foo, Bar), (Foo, Bar))').typeParser.parse().innermost;
    expect(exp, const isInstanceOf<TupleTypeContext>());
    var tuple = exp as TupleTypeContext;
    expect(tuple.items.length, 2);
    expect(tuple.items, everyElement(const isInstanceOf<TupleTypeContext>()));

    for (TupleTypeContext tup in tuple.items) {
      expect(tup.items[0], isNamedType('Foo'));
      expect(tup.items[1], isNamedType('Bar'));
    }
  });
}
