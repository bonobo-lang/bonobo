part of bonobo.src.ast;

class FunctionContext extends ExpressionContext {
  final List<TokenType> modifiers;
  final IdentifierContext name;
  final FunctionSignatureContext signature;
  final FunctionBodyContext body;

  FunctionContext(this.modifiers, this.name, this.signature, this.body,
      FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class FunctionSignatureContext extends AstNode {
  final ParameterListContext parameterList;
  final TypeContext returnType;

  FunctionSignatureContext(this.parameterList, this.returnType, FileSpan span,
      List<Comment> comments)
      : super(span, comments);
}

abstract class FunctionBodyContext extends AstNode {
  FunctionBodyContext(FileSpan span, List<Comment> comments)
      : super(span, comments);

  List<StatementContext> get body;
}

class BlockFunctionBodyContext extends FunctionBodyContext {
  final BlockContext block;

  BlockFunctionBodyContext(this.block) : super(block.span, []);

  @override
  List<StatementContext> get body => block.statements;
}

class LambdaFunctionBodyContext extends FunctionBodyContext {
  final ExpressionContext expression;

  LambdaFunctionBodyContext(
      this.expression, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  List<StatementContext> get body =>
      [new ReturnStatementContext(expression, span, comments)];
}

class ParameterListContext extends AstNode {
  final List<ParameterContext> parameters;

  ParameterListContext(this.parameters, FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class ParameterContext extends AstNode {
  final IdentifierContext name;
  final TypeContext type;

  ParameterContext(this.name, this.type, FileSpan span, List<Comment> comments)
      : super(span, comments);
}
