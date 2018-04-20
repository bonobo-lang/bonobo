part of bonobo.src.ast;

class UnitContext extends AstNode {
  final List<FunctionContext> functions;

  UnitContext(FileSpan span, this.functions) : super(span, []);

  String toString() {
    var sb = new StringBuffer();

    for(FunctionContext fn in functions) {
      sb.writeln(fn);
      sb.writeln();
    }

    return sb.toString();
  }
}
