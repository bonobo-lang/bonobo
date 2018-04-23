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
  
}

class TupleTypeContext extends TypeContext {
  final List<TypeContext> items;

  TupleTypeContext(this.items, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitTupleType(this);

  @override
  String toString() {
    return items.join(', ');
  }
}

class TypedefContext extends AstNode {
  final SimpleIdentifierContext name;
  final TypeContext type;

  TypedefContext(this.name, this.type, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitTypedef(this);
}

class ParenthesizedTypeContext extends TypeContext {
  final TypeContext innermost;

  ParenthesizedTypeContext(
      this.innermost, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => innermost.accept(visitor);

  @override
  String toString() {
    return '($innermost)';
  }
}

class StructTypeContext extends TypeContext {
  final List<StructFieldContext> fields;

  StructTypeContext(this.fields, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitStructType(this);
}

class StructFieldContext extends AstNode {
  final SimpleIdentifierContext name;
  final TypeContext type;

  StructFieldContext(
      this.name, this.type, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitStructField(this);
}

class EnumTypeContext extends TypeContext {
  final List<EnumValueContext> values;

  EnumTypeContext(this.values, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitEnumType(this);
}

class EnumValueContext extends AstNode {
  final SimpleIdentifierContext name;
  final NumberLiteralContext index;

  EnumValueContext(this.name, this.index, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitEnumValue(this);
}

class ClassDeclarationContext extends TypeContext {
  final SimpleIdentifierContext name;

  final bool isPriv;

  // TODO List<Generic> generics;

  // TODO List<Class> interfaces;

  // TODO List<Mixin> mixes;

  final List<VariableDeclarationStatementContext> fields;

  final List<FunctionContext> methods;

  ClassDeclarationContext(FileSpan span, this.name,
      {this.fields: const [], this.methods: const [], this.isPriv: false})
      : super(span, []);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitClassDeclaration(this);

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
