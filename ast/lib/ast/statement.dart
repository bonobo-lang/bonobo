part of bonobo.src.ast;

abstract class StatementContext extends AstNode {
  StatementContext(FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class BlockContext extends AstNode {
  final List<StatementContext> statements;

  BlockContext(this.statements, FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class ExpressionStatementContext extends StatementContext {
  final ExpressionContext expression;

  ExpressionStatementContext(this.expression)
      : super(expression.span, expression.comments);
}

class ReturnStatementContext extends StatementContext {
  final ExpressionContext expression;

  ReturnStatementContext(this.expression, FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class VarDeclStContext extends StatementContext {
  final List<VarDeclContext> declarations;
  // final FileSpan declarationSpan;
  /* TODO
  ControlFlow flow;
  SymbolTable<BonoboObject> scope;
  */

  VarDeclStContext(FileSpan span, this.declarations, List<Comment> comments)
      : super(span, comments);
}

enum VarMut {
  const_,
  final_,
  var_,
}

class VarDeclContext extends AstNode {
  final SimpleIdentifierContext name;
  final TypeContext type;
  final ExpressionContext initializer;
  final VarMut mutability;

  VarDeclContext(FileSpan span, this.name, this.type,
      this.initializer, this.mutability, List<Comment> comments)
      : super(span, comments);
}
