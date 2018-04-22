part of bonobo.src.ast;

class CompilationUnitContext extends AstNode {
  final List<TypedefContext> typedefs;
  final List<FunctionContext> functions;

  final List<ClassDeclarationContext> classes;

  CompilationUnitContext(FileSpan span, List<Comment> comments,
      {this.typedefs, this.functions, this.classes})
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitCompilationUnit(this);

  String toString() {
    var sb = new StringBuffer();

    for (ClassDeclarationContext cl in classes) {
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
