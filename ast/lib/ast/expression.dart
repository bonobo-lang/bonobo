part of bonobo.src.ast;

abstract class ExpressionContext extends AstNode {
  ExpressionContext(FileSpan span, List<Comment> comments)
      : super(span, comments);
}

abstract class IdentifierContext extends ExpressionContext {
  IdentifierContext(FileSpan span, List<Comment> comments)
      : super(span, comments);

  String get name => span.text;
}

class SimpleIdentifierContext extends IdentifierContext {
  final String name;

  SimpleIdentifierContext(FileSpan span, List<Comment> comments)
      : name = span.text,
        super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitSimpleIdentifier(this);

  String toString() => name;
}

class NamespacedIdentifierContext extends IdentifierContext {
  final List<IdentifierContext> namespaces;
  final IdentifierContext symbol;

  NamespacedIdentifierContext(
      this.namespaces, this.symbol, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitNamespacedIdentifier(this);
}

class NumberLiteralContext extends ExpressionContext {
  NumberLiteralContext(FileSpan span, List<Comment> comments)
      : super(span, comments);

  bool get isByte => span.text.endsWith('b');

  bool get hasDecimal => span.text.contains('.');

  double get doubleValue => double.parse(span.text);

  int get intValue {
    if (span.text.endsWith('b'))
      return int.parse(span.text.substring(0, span.length - 1));
    return int.parse(span.text);
  }

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitNumberLiteral(this);

  String toString() => span.text;
}

class StringLiteralContext extends ExpressionContext {
  static final RegExp _unicode = new RegExp(r'\\u([A-Fa-f0-9]+)');
  String _value;

  StringLiteralContext(FileSpan span, List<Comment> comments)
      : super(span, comments);

  String get value {
    if (_value != null) return _value;

    var t = span.text.substring(1, span.length - 1);
    t = t
        .replaceAll('\\b', '\b')
        .replaceAll('\\f', '\f')
        .replaceAll('\\r', '\r')
        .replaceAll('\\n', '\n')
        .replaceAll('\\t', '\t')
        .replaceAllMapped(_unicode, (m) {
      new String.fromCharCode(int.parse(m[1], radix: 16));
    });
    return _value = t;
  }

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitStringLiteral(this);

  String toString() => span.text;
}

class BinaryOperator {
  final int value;

  final String rep;

  final String name;

  final int precedence;

  const BinaryOperator._(this.value, this.rep, this.name, this.precedence);

  static const BinaryOperator mod = const BinaryOperator._(0, '%', 'mod', 10);

  static const BinaryOperator pow = const BinaryOperator._(1, '**', 'pow', 10);

  static const BinaryOperator times = const BinaryOperator._(2, '*', 'times', 10);

  static const BinaryOperator div = const BinaryOperator._(3, '/', 'div', 10);

  // TODO truncated div

  static const BinaryOperator plus = const BinaryOperator._(4, '+', 'plus', 8);

  static const BinaryOperator minus = const BinaryOperator._(5, '-', 'minus', 8);

  static const BinaryOperator xor = const BinaryOperator._(6, '^', 'xor', 8);

  static const BinaryOperator and = const BinaryOperator._(7, '&', 'and', 10);

  static const BinaryOperator or = const BinaryOperator._(8, '|', 'or', 8);

  static const BinaryOperator logicalAnd =
      const BinaryOperator._(9, '&&', 'logical and', 2);

  static const BinaryOperator logicalOr = const BinaryOperator._(10, '||', 'logical or', 4);

  static const BinaryOperator equals = const BinaryOperator._(11, '==', 'eq', 6);

  static const BinaryOperator notEquals = const BinaryOperator._(12, '!=', 'neq', 6);

  static const BinaryOperator lt = const BinaryOperator._(13, '<', 'lt', 6);

  static const BinaryOperator lte = const BinaryOperator._(14, '<=', 'lte', 6);

  static const BinaryOperator gt = const BinaryOperator._(15, '>', 'gt', 6);

  static const BinaryOperator gte = const BinaryOperator._(16, '>=', 'gte', 6);

  static const BinaryOperator shl = const BinaryOperator._(17, '<<', 'shl', 10);

  static const BinaryOperator shr = const BinaryOperator._(18, '>>', 'shr', 10);

  static BinaryOperator fromTokenType(TokenType token) {
    switch (token) {
      case TokenType.mod:
        return mod;
      case TokenType.pow:
        return pow;
      case TokenType.times:
        return times;
      case TokenType.div:
        return div;
      case TokenType.plus:
        return plus;
      case TokenType.minus:
        return minus;
      case TokenType.xor:
        return xor;
      case TokenType.and:
        return and;
      case TokenType.or:
        return or;
      case TokenType.l_and:
        return logicalAnd;
      case TokenType.l_or:
        return logicalOr;
      case TokenType.equals:
        return equals;
      case TokenType.notEquals:
        return notEquals;
      case TokenType.lt:
        return lt;
      case TokenType.lte:
        return lte;
      case TokenType.gt:
        return gt;
      case TokenType.gte:
        return gte;
      case TokenType.shl:
        return shl;
      case TokenType.shr:
        return shr;
      default:
        {
          return null;
        }
    }
  }
}

class BinaryExpression extends AstNode {
  final BinaryOperator op;

  BinaryExpression(FileSpan span, List<Comment> comments, this.op)
      : super(span, comments);

  int get precedence => op.precedence;

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitBinaryExpression(this);

  String toString() => op.rep;
}

class AssignmentExpressionContext extends ExpressionContext {
  final ExpressionContext left, right;
  final Token operator;

  AssignmentExpressionContext(this.left, this.operator, this.right,
      FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitAssignmentExpression(this);
}

class PrefixOp {
  final int value;

  final String rep;

  const PrefixOp(this.value, this.rep);

  static const PrefixOp minus = const PrefixOp(0, '-');

  static const PrefixOp complement = const PrefixOp(1, '~');

  static const PrefixOp not = const PrefixOp(2, '!');

  static Map<TokenType, PrefixOp> _map = const {
    TokenType.minus: minus,
    TokenType.tilde: complement,
    TokenType.not: not,
  };

  static PrefixOp fromToken(TokenType tok) => _map[tok];
}

class PrefixOperatorContext extends AstNode {
  final PrefixOp op;

  PrefixOperatorContext(FileSpan span, List<Comment> comments, this.op)
      : super(span, comments);

  String toString() => op.rep;
}

class PrefixExpressionContext extends ExpressionContext {
  final PrefixOperatorContext op;
  final ExpressionContext exp;

  PrefixExpressionContext(FileSpan span, List<Comment> comments, this.op, this.exp)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitPrefixExpression(this);

  String toString() => '$op$exp';
}

class PostfixExpressionContext extends ExpressionContext {
  final ExpressionContext expression;
  final Token operator;

  PostfixExpressionContext(
      this.expression, this.operator, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitPostfixExpression(this);
}


class ConditionalExpressionContext extends ExpressionContext {
  final ExpressionContext condition, ifTrue, ifFalse;

  ConditionalExpressionContext(this.condition, this.ifTrue, this.ifFalse,
      FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitConditionalExpression(this);
}

class TupleExpressionContext extends ExpressionContext {
  final List<ExpressionContext> expressions;

  TupleExpressionContext(
      this.expressions, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitTupleExpression(this);
}

class CallExpressionContext extends ExpressionContext {
  final ExpressionContext target;
  final TupleExpressionContext arguments;

  CallExpressionContext(
      this.target, this.arguments, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitCallExpression(this);
}

class MemberExpressionContext extends ExpressionContext {
  final ExpressionContext target;
  final SimpleIdentifierContext identifier;

  MemberExpressionContext(
      this.target, this.identifier, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitMemberExpression(this);
}

/*
class ExpChainPartCtx extends AstNode {
  final BinaryExpression op;
  final ExpressionContext right;

  ExpChainPartCtx(FileSpan span, List<Comment> comments, this.op, this.right)
      : super(span, comments);

  int get precedence => op.precedence;

  String toString() => '${op.op.rep} $right';
}

class ExpChainCtx extends ExpressionContext {
  final ExpressionContext left;
  final ExpChainPartCtx rightPart;

  ExpChainCtx(FileSpan span, List<Comment> comments, this.left, this.rightPart)
      : super(span, comments);

  BinaryExpression get op => rightPart.op;

  ExpressionContext get right => rightPart.right;

  String toString() => '($left $rightPart)';
}

class IdChainExpCtx extends ExpressionContext {
  final IdentifierContext target;
  final List<IdChainExpPartCtx> parts;

  IdChainExpCtx(FileSpan span, List<Comment> comments, this.target, this.parts)
      : super(span, comments);

  String toString() => target.toString() + parts.join();
}

abstract class IdChainExpPartCtx implements AstNode {}

class CallIdChainExpPartCtx extends AstNode implements IdChainExpPartCtx {
  final List<ExpressionContext> args;

  CallIdChainExpPartCtx(FileSpan span, List<Comment> comments, this.args)
      : super(span, comments);

  String toString() => '(' + args.join(', ') + ')';
}
*/