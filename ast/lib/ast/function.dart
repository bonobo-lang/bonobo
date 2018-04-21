part of bonobo.src.ast;

class FunctionContext extends ExpressionContext {
  final bool isPriv;

  final IdentifierContext name;
  final FunctionSignatureContext signature;
  final FunctionBodyContext body;

  FunctionContext(this.name, this.signature, this.body, FileSpan span,
      List<Comment> comments,
      {this.isPriv: false})
      : super(span, comments);

  String toString() {
    var sb = new StringBuffer();
    sb.write('fn');
    if(isPriv) sb.write(' hide');
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

  String toString() => block.toString();
}

class SameLineFnBodyContext extends FunctionBodyContext {
  final List<ExpressionContext> expressions;

  SameLineFnBodyContext(FileSpan span, List<Comment> comments, this.expressions)
      : super(span, comments);

  @override
  List<StatementContext> get body =>
      [new ReturnStatementContext(span, comments, expressions)];

  String toString() {
    return ' => ' + expressions.join(', ');
  }
}

class ParameterListContext extends AstNode {
  final List<ParameterContext> parameters;

  ParameterListContext(FileSpan span, List<Comment> comments, this.parameters)
      : super(span, comments);

  String toString() =>
      '(' + parameters.join(', ') + ')';
}

class ParameterContext extends AstNode {
  final IdentifierContext name;
  final TypeContext type;

  ParameterContext(this.name, this.type, FileSpan span, List<Comment> comments)
      : super(span, comments);

  String toString() => '$name: $type';
}
