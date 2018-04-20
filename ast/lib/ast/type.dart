part of bonobo.src.ast;

class TypeContext extends AstNode {
  final List<IdentifierContext> namespaces;
  final SimpleIdentifierContext symbol;
  final List<TypeContext> generics;

  TypeContext(FileSpan span, List<Comment> comments, this.symbol,
      {this.namespaces: const [], this.generics: const []})
      : super(span, comments);
  
  String toString() {
    var sb = new StringBuffer();
    sb.write(namespaces.map((n) => n.toString()).join('::'));
    sb.write(symbol);
    if(generics.length != 0) {
      sb.write('<');
      sb.write(generics.map((g) => g.toString()).join(', '));
      sb.write('>');
    }
    return sb.toString();
  }
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

class ClassDeclContext extends AstNode {
  final SimpleIdentifierContext name;

  final bool isPriv;

  // TODO List<Generic> generics;

  // TODO List<Class> interfaces;

  // TODO List<Mixin> mixes;

  final List<VarDeclStContext> fields;

  final List<FunctionContext> methods;

  ClassDeclContext(FileSpan span, this.name,
      {this.fields: const [], this.methods: const [], this.isPriv: false})
      : super(span, []);

  String toString() {
    var sb = new StringBuffer();
    sb.write('class');
    if(isPriv) sb.write(' hide');
    sb.write(' ${name.name}');
    // TODO generics
    // TODO interfaces
    // TODO mixins
    sb.writeln(' {');

    for(VarDeclStContext st in fields) {
      sb.writeln(st);
      sb.writeln();
    }

    for(FunctionContext fn in methods) {
      sb.writeln(fn);
      sb.writeln();
    }

    sb.writeln('}');
    return sb.toString();
  }
}
