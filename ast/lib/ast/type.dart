part of bonobo.src.ast;

abstract class TypeContext extends AstNode {
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
    if (generics.length != 0) {
      sb.write('<');
      sb.write(generics.join(', '));
      sb.write('>');
    }
    return sb.toString();
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

class TupleInitCtx extends ExpressionContext {
  final List<ExpressionContext> items;
  
  TupleInitCtx(FileSpan span, List<Comment> comments, this.items)
  
}

class TypedefContext extends AstNode {
  final SimpleIdentifierContext name;
  final TypeContext type;


  TypedefContext(this.name, this.type, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitTypedef(this);
}

class ListInitCtx extends ExpressionContext {
  final List<ExpressionContext> items;
  
  ListInitCtx(FileSpan span, List<Comment> comments, this.items)
      : super(span, comments);
      
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

class MapInitCtx extends ExpressionContext {
  final List<ExpressionContext> keys;
  final List<ExpressionContext> values;

  MapInitCtx(FileSpan span, List<Comment> comments, this.keys, this.values)
      : super(span, comments);
}

class RangeCtx extends ExpressionContext {
  final ExpressionContext start;
  final ExpressionContext end;
  final ExpressionContext step;

  RangeCtx(
      FileSpan span, List<Comment> comments, this.start, this.end, this.step)
      : super(span, comments);
}

class ClassDeclarationContext extends AstNode {
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
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitClassDeclaration(this);

  String toString() {
    var sb = new StringBuffer();
    sb.write('class');
    if (isPriv) sb.write(' hide');
    sb.write(' ${name.name}');
    // TODO generics
    // TODO interfaces
    // TODO mixins
    sb.writeln(' {');

    for(VariableDeclarationStatementContext st in fields) {
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