part of bonobo.src.ast;

class UnitContext extends AstNode {
  final List<FunctionContext> functions;

  final List<ClassDeclContext> classes;

  UnitContext(FileSpan span, {this.functions, this.classes}) : super(span, []);

  String toString() {
    var sb = new StringBuffer();

    for (ClassDeclContext cl in classes) {
      sb.writeln(cl);
      sb.writeln();
    }

    for (FunctionContext fn in functions) {
      sb.writeln(fn);
      sb.writeln();
    }

    return sb.toString();
  }
}

class ClassDeclContext extends AstNode {
  final SimpleIdentifierContext name;

  final bool isPub;

  // TODO List<Generic> generics;

  // TODO List<Class> interfaces;

  // TODO List<Mixin> mixes;

  final List<VarDeclStContext> fields;

  final List<FunctionContext> methods;

  ClassDeclContext(FileSpan span, this.name,
      {this.fields: const [], this.methods: const [], this.isPub: false})
      : super(span, []);

  String toString() {
    var sb = new StringBuffer();
    sb.write('class');
    if(isPub) sb.write(' pub');
    sb.write(' ${name.name}');
    // TODO generics
    // TODO interfaces
    // TODO mixins
    sb.writeln(' {');
    // TODO
    sb.writeln('}');
    return sb.toString();
  }
}
