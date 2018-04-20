part of bonobo.src.ast;

abstract class TypeContext extends AstNode {
  TypeContext(FileSpan span, List<Comment> comments) : super(span, comments);

  TypeContext get innermost => this;
}

class SimpleIdentifierTypeContext extends TypeContext {
  final IdentifierContext identifier;

  SimpleIdentifierTypeContext(this.identifier, List<Comment> comments)
      : super(identifier.span, comments);
}

class NamespacedIdentifierTypeContext extends TypeContext {
  final NamespacedIdentifierContext identifier;

  NamespacedIdentifierTypeContext(this.identifier, List<Comment> comments)
      : super(identifier.span, comments);
}

class TupleTypeContext extends TypeContext {
  final List<TypeContext> items;

  TupleTypeContext(this.items, FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class ParenthesizedTypeContext extends TypeContext {
  @override
  final TypeContext innermost;

  ParenthesizedTypeContext(
      this.innermost, FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class TypedefContext extends AstNode {
  final SimpleIdentifierContext name;
  final TypeContext type;

  TypedefContext(this.name, this.type, FileSpan span, List<Comment> comments)
      : super(span, comments);
}
