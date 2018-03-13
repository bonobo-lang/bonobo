part of bonobo.src.ast;

class CompilationUnitContext extends AstNode {
  final List<FunctionContext> functions;

  CompilationUnitContext(FileSpan span, this.functions):super(span, []);
}