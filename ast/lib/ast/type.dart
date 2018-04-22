part of bonobo.src.ast;

abstract class TypeContext implements AstNode {}

class NamedTypeContext extends AstNode implements TypeContext {
  final NamespacedIdentifierContext typeName;
  final List<TypeContext> generics; // TODO List<NamedTypeContext>?

  NamedTypeContext(FileSpan span, List<Comment> comments, this.typeName,
      {this.generics: const []})
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitNamedType(this);

  String toString() {
    var sb = new StringBuffer();
    sb.write(typeName.toString());
    if (generics.length != 0) {
      sb.write('<');
      sb.write(generics.join(', '));
      sb.write('>');
    }
    return sb.toString();
  }
}

class FunctionTypeContext extends AstNode implements TypeContext {
  final FunctionSignatureContext signature;
  // TODO modifiers?

  FunctionTypeContext(FileSpan span, List<Comment> comments, this.signature)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitFunctionType(this);
}

class AnonymousTypeContext extends AstNode implements TypeContext {
  final VariableDeclarationStatementContext fields;

  AnonymousTypeContext(FileSpan span, List<Comment> comments, this.fields)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitAnonymousType(this);
}
