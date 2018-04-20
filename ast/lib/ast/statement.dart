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
  final VarMut mutability;

  final List<VarDeclContext> declarations;

  VarDeclStContext(FileSpan span, this.mutability, this.declarations, List<Comment> comments)
      : super(span, comments);

  String toString() {
    var sb = new StringBuffer();
    sb.write(mutability.rep);
    sb.write(' ');
    sb.write(declarations.map((v) => v.toString()).join(', '));
    return sb.toString();
  }
}

class VarMut {
  final int value;

  final String rep;

  const VarMut(this.value, this.rep);

  static const VarMut const_ = const VarMut(0, 'const');
  static const VarMut final_ = const VarMut(0, 'let');
  static const VarMut var_ = const VarMut(0, 'var');
}

class VarDeclContext extends AstNode {
  final SimpleIdentifierContext name;
  final TypeContext type;
  final ExpressionContext initializer;
  final VarMut mutability;

  VarDeclContext(FileSpan span, this.name, this.type, this.initializer,
      this.mutability, List<Comment> comments)
      : super(span, comments);

  String toString() {
    var sb = new StringBuffer();
    sb.write(name);
    if(type != null) sb.write(': $type');
    if(initializer != null) sb.write(' = $initializer');
    return sb.toString();
  }
}
