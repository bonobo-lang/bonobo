part of bonobo.src.ast;

class CompilationUnitContext extends AstNode {
  final List<FunctionContext> functions;
  //final List<TypeDeclarationContext> classes;
  final List<TypedefContext> typedefs;
  //final List<EnumDeclarationContext> enums;

  CompilationUnitContext(this.functions, this.typedefs, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitCompilationUnit(this);

  /*
  String toString() {
    var sb = new StringBuffer();

    /*
    for (TypeDeclarationContext cl in classes) {
      sb.writeln(cl);
      sb.writeln();
    }

    for (EnumDeclarationContext en in enums) {
      sb.writeln(en);
      sb.writeln();
    }

    for (FunctionContext fn in functions) {
      sb.writeln(fn);
      sb.writeln();
    }*/

    return sb.toString();
  }*/
}
