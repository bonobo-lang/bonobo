part of bonobo.src.ast;

class CompilationUnitContext extends AstNode {
  final List<TypedefContext> typedefs;
  final List<FunctionContext> functions;

  CompilationUnitContext(FileSpan span, this.typedefs, this.functions):super(span, []);
}

