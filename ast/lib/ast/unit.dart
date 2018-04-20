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
