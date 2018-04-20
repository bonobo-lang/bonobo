part of bonobo.src.ast;

abstract class TypeContext extends AstNode {
  final List<IdentifierContext> namespaces;
  final IdentifierContext name;
  final List<TypeContext> generics;

  TypeContext(FileSpan span, List<Comment> comments, this.name,
      {this.namespaces: const [], this.generics: const []})
      : super(span, comments);

  TypeContext get innermost => this;
}

/*
class TupleTypeContext extends TypeContext {
  final List<TypeContext> items;

  TupleTypeContext(this.items, FileSpan span, List<Comment> comments)
      : super(span, comments);
}
*/

class TypedefContext extends AstNode {
  final SimpleIdentifierContext name;
  final TypeContext type;

  TypedefContext(this.name, this.type, FileSpan span, List<Comment> comments)
      : super(span, comments);
}
