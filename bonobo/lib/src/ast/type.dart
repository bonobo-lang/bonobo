part of bonobo.src.ast;

abstract class TypeContext extends AstNode {
  TypeContext(FileSpan span, List<Comment> comments) : super(span, comments);

  TypeContext get innermost => this;
}

class SimpleIdentifierTypeContext extends TypeContext {
  final IdentifierContext identifier;

  SimpleIdentifierTypeContext(this.identifier, List<Comment> comments)
      : super(identifier.span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitSimpleIdentifierType(this);
}

class NamespacedIdentifierTypeContext extends TypeContext {
  final NamespacedIdentifierContext identifier;

  NamespacedIdentifierTypeContext(this.identifier, List<Comment> comments)
      : super(identifier.span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitNamespacedIdentifierType(this);
}

class TupleTypeContext extends TypeContext {
  final List<TypeContext> items;

  TupleTypeContext(this.items, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitTupleType(this);
}

class ParenthesizedTypeContext extends TypeContext {
  @override
  final TypeContext innermost;

  ParenthesizedTypeContext(
      this.innermost, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitParenthesizedType(this);
}

class TypedefContext extends AstNode {
  final SimpleIdentifierContext name;
  final TypeContext type;

  TypedefContext(this.name, this.type, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitTypedef(this);
}

class FunctionTypeContext extends TypeContext {
  final List<TypeContext> parameters;
  final TypeContext returnType;

  FunctionTypeContext(
      this.parameters, this.returnType, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitFunctionType(this);
}
