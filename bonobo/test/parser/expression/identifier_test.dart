import 'package:bonobo/ast/ast.dart';
import 'package:test/test.dart';
import '../util.dart';

void main() {
  test('simple identifier', () {
    var id = parse('foo').parseIdentifier();
    expect(id, const isInstanceOf<IdentifierContext>());
    expect(id.name, 'foo');
  });

  test('namespaced identifier', () {
    var id = parse('foo::bar::baz').parseIdentifier();
    expect(id, const isInstanceOf<NamespacedIdentifierContext>());
    var nid = id as NamespacedIdentifierContext;
    expect(nid.namespaces, hasLength(2));
    expect(nid.namespaces[0].name, 'foo');
    expect(nid.namespaces[1].name, 'bar');
    expect(nid.symbol.name, 'baz');
    expect(nid.name, 'foo::bar::baz');
  });
}
