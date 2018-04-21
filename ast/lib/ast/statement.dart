part of bonobo.src.ast;

abstract class StatementContext extends AstNode {
  StatementContext(FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class BlockContext extends AstNode {
  final List<StatementContext> statements;

  BlockContext(this.statements, FileSpan span, List<Comment> comments)
      : super(span, comments);

  String toString() {
    var sb = new StringBuffer();
    sb.writeln(' {');
    sb.write(statements.join('\n'));
    sb.writeln();
    sb.writeln('}');
    return sb.toString();
  }
}

class AssignOp {
  final int value;

  final String rep;

  const AssignOp._(this.value, this.rep);

  static const AssignOp assign = const AssignOp._(0, '=');

  static const AssignOp add = const AssignOp._(0, '+=');

  static const AssignOp sub = const AssignOp._(0, '-=');

  static const AssignOp times = const AssignOp._(0, '*=');

  static const AssignOp div = const AssignOp._(0, '/=');

  static const AssignOp mod = const AssignOp._(0, '%=');

  static const AssignOp and = const AssignOp._(0, '&=');

  static const AssignOp or = const AssignOp._(0, '|=');

  static const AssignOp xor = const AssignOp._(0, '^=');

  static const AssignOp shl = const AssignOp._(0, '<<=');

  static const AssignOp shr = const AssignOp._(0, '>>=');

  static AssignOp fromToken(TokenType tok) {
    switch (tok) {
      case TokenType.assign:
        return assign;
      case TokenType.assignAdd:
        return add;
      case TokenType.assignSub:
        return sub;
      case TokenType.assignTimes:
        return times;
      case TokenType.assignDiv:
        return div;
      case TokenType.assignMod:
        return mod;
      case TokenType.assignAnd:
        return and;
      case TokenType.assignOr:
        return or;
      case TokenType.assignXor:
        return xor;
      case TokenType.assignShl:
        return shl;
      case TokenType.assignShr:
        return shr;
      default:
        return null;
    }
  }
}

class AssignOpCtx extends AstNode {
  final AssignOp op;

  AssignOpCtx(FileSpan span, List<Comment> comments, this.op)
      : super(span, comments);

  String toString() => op.rep;
}

class AssignStCtx extends StatementContext {
  final ExpressionContext left, right;
  final AssignOpCtx op;

  AssignStCtx(
      FileSpan span, List<Comment> comments, this.left, this.op, this.right)
      : super(span, comments);

  String toString() => '$left $op $right';
}

class ExpressionStatementContext extends StatementContext {
  final ExpressionContext expression;

  ExpressionStatementContext(this.expression)
      : super(expression.span, expression.comments);

  String toString() => expression.toString();
}

class ReturnStatementContext extends StatementContext {
  final List<ExpressionContext> expressions;

  ReturnStatementContext(
      FileSpan span, List<Comment> comments, this.expressions)
      : super(span, comments);
}

class VarDeclStContext extends StatementContext {
  final VarMut mutability;

  final List<VarDeclContext> declarations;

  VarDeclStContext(
      FileSpan span, this.mutability, this.declarations, List<Comment> comments)
      : super(span, comments);

  String toString() {
    var sb = new StringBuffer();
    sb.write(mutability.rep);
    sb.write(' ');
    sb.write(declarations.join(', '));
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
    if (type != null) sb.write(': $type');
    if (initializer != null) sb.write(' = $initializer');
    return sb.toString();
  }
}
