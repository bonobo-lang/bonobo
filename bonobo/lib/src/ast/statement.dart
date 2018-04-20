part of bonobo.src.ast;

abstract class StatementContext extends AstNode {
  StatementContext(FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class BlockContext extends AstNode {
  final List<StatementContext> statements;

  BlockContext(this.statements, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitBlock(this);
}

class ExpressionStatementContext extends StatementContext {
  final ExpressionContext expression;

  ExpressionStatementContext(this.expression)
      : super(expression.span, expression.comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitExpressionStatement(this);
}

class ReturnStatementContext extends StatementContext {
  final ExpressionContext expression;

  ReturnStatementContext(this.expression, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitReturnStatement(this);
}

class VariableDeclarationStatementContext extends StatementContext {
  final List<VariableDeclarationContext> declarations;
  final List<StatementContext> context;
  final FileSpan declarationSpan;
  ControlFlow flow;
  SymbolTable<BonoboObject> scope;

  VariableDeclarationStatementContext(this.declarations, this.context,
      this.declarationSpan, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitVariableDeclarationStatement(this);
}

class VariableDeclarationContext extends AstNode {
  final IdentifierContext name;
  final ExpressionContext expression;
  final bool isFinal;

  VariableDeclarationContext(this.name, this.expression, this.isFinal,
      FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitVariableDeclaration(this);
}
