part of bonobo.src.ast;

class FunctionContext extends ExpressionContext {
  final bool isPub;

  final IdentifierContext name;
  final FunctionSignatureContext signature;
  final FunctionBodyContext body;

  FunctionContext(this.name, this.signature, this.body, FileSpan span,
      List<Comment> comments,
      {this.isPub: false})
      : super(span, comments);

  String toString() {
    var sb = new StringBuffer();
    sb.write('fn');
    if(isPub) sb.write(' pub');
    sb.write(' $name');
    if (signature != null) sb.write(signature);
    sb.write(body);
    return sb.toString();
  }
}

class FunctionSignatureContext extends AstNode {
  final ParameterListContext parameterList;
  final TypeContext returnType;

  FunctionSignatureContext(this.parameterList, this.returnType, FileSpan span,
      List<Comment> comments)
      : super(span, comments);

  String toString() {
    var sb = new StringBuffer();
    if (parameterList != null) sb.write(parameterList);
    if (returnType != null) sb.write(': $returnType ');
    return sb.toString();
  }
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

  String toString() {
    var sb = new StringBuffer();
    throw new UnimplementedError();
    // TODO
    return sb.toString();
  }
}

class SameLineFnBodyContext extends FunctionBodyContext {
  final ExpressionContext expression;

  SameLineFnBodyContext(this.expression, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  List<StatementContext> get body =>
      [new ReturnStatementContext(expression, span, comments)];

  String toString() {
    return ' => $expression';
  }
}

class ParameterListContext extends AstNode {
  final List<ParameterContext> parameters;

  ParameterListContext(this.parameters, FileSpan span, List<Comment> comments)
      : super(span, comments);

  String toString() =>
      '(' + parameters.map((p) => p.toString()).join(', ') + ')';
}

class ParameterContext extends AstNode {
  final IdentifierContext name;
  final TypeContext type;

  ParameterContext(this.name, this.type, FileSpan span, List<Comment> comments)
      : super(span, comments);

  String toString() => '$name: $type';
}
