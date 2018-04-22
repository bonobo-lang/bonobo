part of bonobo.src.ast;

abstract class TypeContext implements AstNode {}

class NamedTypeContext extends AstNode implements TypeContext {
  final List<SimpleIdentifierContext> namespaces;
  final SimpleIdentifierContext symbol;
  final List<TypeContext> generics; // TODO List<NamedTypeContext>?

  NamedTypeContext(FileSpan span, List<Comment> comments, this.symbol,
      {this.namespaces: const [], this.generics: const []})
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitNamedType(this);

  String toString() {
    var sb = new StringBuffer();
    sb.write(namespaces.join('::'));
    sb.write(symbol);
    if (generics.length != 0) {
      sb.write('<');
      sb.write(generics.join(', '));
      sb.write('>');
    }
    return sb.toString();
  }
}

class FunctionTypeCtx extends AstNode implements TypeContext {
  final FunctionSignatureContext signature;
  // TODO modifiers?

  FunctionTypeCtx(FileSpan span, List<Comment> comments, this.signature)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitFunctionType(this);
}

class AnonymousTypeCtx extends AstNode implements TypeContext {
  final VarDeclarationStatementContext fields;

  AnonymousTypeCtx(FileSpan span, List<Comment> comments, this.fields)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitAnonymousType(this);
}

class TypeDeclarationContext extends AstNode {
  final SimpleIdentifierContext name;

  final bool isPriv;

  // TODO List<Generic> generics;

  // TODO List<Class> interfaces;

  // TODO List<Mixin> mixes;

  final List<VarDeclarationStatementContext> fields;

  final List<FunctionContext> methods;

  TypeDeclarationContext(FileSpan span, this.name,
      {this.fields: const [], this.methods: const [], this.isPriv: false})
      : super(span, []);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitTypeDeclaration(this);

  String toString() {
    var sb = new StringBuffer();
    sb.write('class');
    if (isPriv) sb.write(' hide');
    sb.write(' ${name.name}');
    // TODO generics
    // TODO interfaces
    // TODO mixins
    sb.writeln(' {');

    for (VarDeclarationStatementContext st in fields) {
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
