part of bonobo.src.ast;

class UnitContext extends AstNode {
  final List<FunctionContext> functions;

  UnitContext(FileSpan span, this.functions) : super(span, []);
}
