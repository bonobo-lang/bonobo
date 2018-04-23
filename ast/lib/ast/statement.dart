<<<<<<< HEAD
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

  String toString() {
    var sb = new StringBuffer();
    sb.writeln(' {');
    sb.write(statements.join('\n'));
    sb.writeln();
    sb.writeln('}');
    return sb.toString();
  }
}

class AssignmentOperator {
  final int value;

  final String rep;

  const AssignmentOperator._(this.value, this.rep);

  static const AssignmentOperator assign = const AssignmentOperator._(0, '=');

  static const AssignmentOperator add = const AssignmentOperator._(0, '+=');

  static const AssignmentOperator sub = const AssignmentOperator._(0, '-=');

  static const AssignmentOperator times = const AssignmentOperator._(0, '*=');

  static const AssignmentOperator div = const AssignmentOperator._(0, '/=');

  static const AssignmentOperator mod = const AssignmentOperator._(0, '%=');

  static const AssignmentOperator and = const AssignmentOperator._(0, '&=');

  static const AssignmentOperator or = const AssignmentOperator._(0, '|=');

  static const AssignmentOperator xor = const AssignmentOperator._(0, '^=');

  static const AssignmentOperator shl = const AssignmentOperator._(0, '<<=');

  static const AssignmentOperator shr = const AssignmentOperator._(0, '>>=');

  static AssignmentOperator fromToken(TokenType tok) {
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

class AssignmentOperatorContext {
  final FileSpan span;
  final List<Comment> comments;
  final AssignmentOperator op;

  AssignmentOperatorContext(this.span, this.comments, this.op);

  String toString() => op.rep;
}

/*
class AssignStCtx extends StatementContext {
  final ExpressionContext left, right;
  final AssignmentOperatorContext op;

  AssignStCtx(
      FileSpan span, List<Comment> comments, this.left, this.op, this.right)
      : super(span, comments);

  String toString() => '$left $op $right';
}*/

class ExpressionStatementContext extends StatementContext {
  final ExpressionContext expression;

  ExpressionStatementContext(this.expression)
      : super(expression.span, expression.comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitExpressionStatement(this);

  String toString() => expression.toString();
}

class ReturnStatementContext extends StatementContext {
  final ExpressionContext expression;

  ReturnStatementContext(FileSpan span, List<Comment> comments, this.expression)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitReturnStatement(this);
}

/*
class VarDeclStContext extends StatementContext {
  final VariableMutability mutability;

  final List<VariableDeclarationContext> declarations;

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
}*/

class VariableMutability {
  final int value;

  final String rep;

  const VariableMutability(this.value, this.rep);

  static const VariableMutability const_ = const VariableMutability(0, 'const');
  static const VariableMutability final_ = const VariableMutability(0, 'let');
  static const VariableMutability var_ = const VariableMutability(0, 'var');

  bool operator <(VariableMutability other) => value < other.value;
  bool operator <=(VariableMutability other) => value <= other.value;

  bool operator >(VariableMutability other) => value > other.value;
  bool operator >=(VariableMutability other) => value >= other.value;
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
  final SimpleIdentifierContext name;
  final TypeContext type;
  final ExpressionContext initializer;
  final VariableMutability mutability;

  VariableDeclarationContext(FileSpan span, this.name, this.type,
      this.initializer, this.mutability, List<Comment> comments)
      : super(span, comments);

  bool get isImmutable => mutability >= VariableMutability.final_;

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitVariableDeclaration(this);

  String toString() {
    var sb = new StringBuffer();
    sb.write(name);
    if (type != null) sb.write(': $type');
    if (initializer != null) sb.write(' = $initializer');
    return sb.toString();
  }
}
=======
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

  String toString() {
    var sb = new StringBuffer();
    sb.writeln(' {');
    sb.write(statements.join('\n'));
    sb.writeln();
    sb.writeln('}');
    return sb.toString();
  }
}

class AssignOperator {
  final int value;

  final String rep;

  const AssignOperator._(this.value, this.rep);

  static const AssignOperator assign = const AssignOperator._(0, '=');

  static const AssignOperator add = const AssignOperator._(0, '+=');

  static const AssignOperator sub = const AssignOperator._(0, '-=');

  static const AssignOperator times = const AssignOperator._(0, '*=');

  static const AssignOperator div = const AssignOperator._(0, '/=');

  static const AssignOperator mod = const AssignOperator._(0, '%=');

  static const AssignOperator and = const AssignOperator._(0, '&=');

  static const AssignOperator or = const AssignOperator._(0, '|=');

  static const AssignOperator xor = const AssignOperator._(0, '^=');

  static const AssignOperator shl = const AssignOperator._(0, '<<=');

  static const AssignOperator shr = const AssignOperator._(0, '>>=');

  static const Map<TokenType, AssignOperator> _map = const {
    TokenType.assign: assign,
    TokenType.assignAdd: add,
    TokenType.assignSub: sub,
    TokenType.assignTimes: times,
    TokenType.assignDiv: div,
    TokenType.assignMod: mod,
    TokenType.assignAnd: and,
    TokenType.assignOr: or,
    TokenType.assignXor: xor,
    TokenType.assignShl: shl,
    TokenType.assignShr: shr,
  };

  static AssignOperator fromToken(TokenType tok) => _map[tok];
}

class AssignOperatorContext {
  final FileSpan span;
  final List<Comment> comments;
  final AssignOperator op;

  AssignOperatorContext(this.span, this.comments, this.op);

  String toString() => op.rep;
}

class AssignStatementContext extends StatementContext {
  final ExpressionContext left, right;
  final AssignOperatorContext op;

  AssignStatementContext(
      FileSpan span, List<Comment> comments, this.left, this.op, this.right)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitAssignStatement(this);

  String toString() => '$left $op $right';
}

class ExpressionStatementContext extends StatementContext {
  final ExpressionContext expression;

  ExpressionStatementContext(this.expression)
      : super(expression.span, expression.comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitExpressionStatement(this);

  String toString() => expression.toString();
}

class ReturnStatementContext extends StatementContext {
  final ExpressionContext expression;

  ReturnStatementContext(FileSpan span, List<Comment> comments, this.expression)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitReturnStatement(this);
}

class VariableMutability {
  final int value;

  final String rep;

  const VariableMutability(this.value, this.rep);

  static const VariableMutability const_ = const VariableMutability(0, 'const');
  static const VariableMutability final_ = const VariableMutability(0, 'let');
  static const VariableMutability var_ = const VariableMutability(0, 'var');

  bool operator <(VariableMutability other) => value < other.value;
  bool operator <=(VariableMutability other) => value <= other.value;

  bool operator >(VariableMutability other) => value > other.value;
  bool operator >=(VariableMutability other) => value >= other.value;
}

class VariableDeclarationStatementContext extends StatementContext {
  final VariableMutability mutability;
  final List<VariableDeclarationContext> declarations;
  /*
  final List<StatementContext> context;
  final FileSpan declarationSpan;
  ControlFlow flow;
  SymbolTable<BonoboObject> scope;
  */

  VariableDeclarationStatementContext(
      FileSpan span, List<Comment> comments, this.mutability, this.declarations)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitVariableDeclarationStatement(this);
}

class VariableDeclarationContext extends AstNode {
  final SimpleIdentifierContext name;
  final TypeContext type;
  final ExpressionContext initializer;
  final VariableMutability mutability;

  VariableDeclarationContext(FileSpan span, List<Comment> comments,
      this.mutability, this.name, this.type, this.initializer)
      : super(span, comments);

  bool get isImmutable => mutability >= VariableMutability.final_;

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitVariableDeclaration(this);

  String toString() {
    var sb = new StringBuffer();
    sb.write(name);
    if (type != null) sb.write(': $type');
    if (initializer != null) sb.write(' = $initializer');
    return sb.toString();
  }
}

class ForStatementContext extends StatementContext {
  final List<SimpleIdentifierContext> vars;
  final ExpressionContext exp;
  final BlockContext body;

  ForStatementContext(
      FileSpan span, List<Comment> comments, this.vars, this.exp, this.body)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitForStatement(this);

  String toString() {
    throw new UnimplementedError();
  }
}
>>>>>>> a74882f7d754f12d199f21700d9b663870b2711d
