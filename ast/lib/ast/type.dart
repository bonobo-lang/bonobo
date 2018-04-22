part of bonobo.src.ast;

abstract class TypeContext extends AstNode {
  //final List<TypeContext> generics;
  TypeContext(FileSpan span, List<Comment> comments) : super(span, comments);

  TypeContext get innermost => this;
}

class SimpleIdentifierTypeContext extends TypeContext {
  final IdentifierContext identifier;

  SimpleIdentifierTypeContext(this.identifier, List<Comment> comments)
      : super(identifier.span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitSimpleIdentifierType(this);

  @override
  String toString() => identifier.toString();
}

class NamespacedIdentifierTypeContext extends TypeContext {
  final NamespacedIdentifierContext identifier;

  NamespacedIdentifierTypeContext(this.identifier, List<Comment> comments)
      : super(identifier.span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitNamespacedIdentifierType(this);

  @override
  String toString() => identifier.toString();
}

class TupleTypeContext extends TypeContext {
  final List<TypeContext> items;

  TupleTypeContext(this.items, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitTupleType(this);
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
}

class StructTypeContext extends TypeContext {
  final List<StructFieldContext> fields;

  StructTypeContext(this.fields, FileSpan span, List<Comment> comments) : super(span, comments);

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

  EnumTypeContext(this.values, FileSpan span, List<Comment> comments) : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitEnumType(this);
}

class EnumValueContext extends AstNode {
  final SimpleIdentifierContext name;
  final NumberLiteralContext index;

  EnumValueContext(this.name, this.index, FileSpan span, List<Comment> comments) : super(span, comments);

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
    sb.write('class');
    if (isPriv) sb.write(' hide');
    sb.write(' ${name.name}');
    // TODO generics
    // TODO interfaces
    // TODO mixins
    sb.writeln(' {');

    for (VariableDeclarationStatementContext st in fields) {
      sb.writeln(st);
      sb.writeln();
    }

    for (FunctionContext fn in methods) {
      sb.writeln(fn);
      sb.writeln();
    }

    sb.writeln('}');
    return sb.toString();
  }
}

/*
class TypeContext extends AstNode {
  final List<IdentifierContext> namespaces;
  final SimpleIdentifierContext symbol;
  final List<TypeContext> generics;

  TypeContext(FileSpan span, List<Comment> comments, this.symbol,
      {this.namespaces: const [], this.generics: const []})
      : super(span, comments);

  String toString() {
    var sb = new StringBuffer();
    sb.write(namespaces.join('::'));
    sb.write(symbol);
    if(generics.length != 0) {
      sb.write('<');
      sb.write(generics.join(', '));
      sb.write('>');
    }
    return sb.toString();
  }
}*/

/*
class TupleTypeContext extends TypeContext {
  final List<TypeContext> items;

  TupleTypeContext(this.items, FileSpan span, List<Comment> comments)
      : super(span, comments);
}
*/
