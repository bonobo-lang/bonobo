part of bonobo.src.ast;

class ExpressionContext extends AstNode {
  ExpressionContext(FileSpan span, List<Comment> comments)
      : super(span, comments);

  ExpressionContext get innermost => this;
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

  String toString() => name;
}

class NamespacedIdentifierContext extends IdentifierContext {
  final List<IdentifierContext> namespaces;
  final IdentifierContext symbol;

  NamespacedIdentifierContext(
      this.namespaces, this.symbol, FileSpan span, List<Comment> comments)
      : super(span, comments);
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

  String toString() => span.text;
}

class ParenthesizedExpressionContext extends ExpressionContext {
  final ExpressionContext expression;

  ParenthesizedExpressionContext(
      this.expression, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  ExpressionContext get innermost => expression.innermost;
}

class PrefixExpressionContext extends ExpressionContext {
  final Token operator;
  final ExpressionContext expression;

  PrefixExpressionContext(
      this.operator, this.expression, FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class PostfixExpressionContext extends ExpressionContext {
  final ExpressionContext expression;
  final Token operator;

  PostfixExpressionContext(
      this.expression, this.operator, FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class AssignmentExpressionContext extends ExpressionContext {
  final ExpressionContext left, right;
  final Token operator;

  AssignmentExpressionContext(this.left, this.operator, this.right,
      FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class BinaryOp {
  final int value;

  final String rep;

  final String name;

  const BinaryOp._(this.value, this.rep, this.name);

  static const BinaryOp mod = const BinaryOp._(0, '%', 'mod');

  static const BinaryOp pow = const BinaryOp._(1, '**', 'pow');

  static const BinaryOp times = const BinaryOp._(2, '*', 'times');

  static const BinaryOp div = const BinaryOp._(3, '/', 'div');

  // TODO truncated div

  static const BinaryOp plus = const BinaryOp._(4, '+', 'plus');

  static const BinaryOp minus = const BinaryOp._(5, '-', 'minus');

  static const BinaryOp xor = const BinaryOp._(6, '^', 'xor');

  static const BinaryOp and = const BinaryOp._(7, '&', 'and');

  static const BinaryOp or = const BinaryOp._(8, '|', 'or');

  static const BinaryOp logicalAnd = const BinaryOp._(9, '&&', 'logical and');

  static const BinaryOp logicalOr = const BinaryOp._(10, '||', 'logical or');

  static const BinaryOp equals = const BinaryOp._(11, '==', 'eq');

  static const BinaryOp notEquals = const BinaryOp._(12, '!=', 'neq');

  static const BinaryOp lt = const BinaryOp._(13, '<', 'lt');

  static const BinaryOp lte = const BinaryOp._(14, '<=', 'lte');

  static const BinaryOp gt = const BinaryOp._(15, '>', 'gt');

  static const BinaryOp gte = const BinaryOp._(16, '>=', 'gte');

  static const BinaryOp shl = const BinaryOp._(17, '<<', 'shl');

  static const BinaryOp shr = const BinaryOp._(18, '>>', 'shr');

  static BinaryOp fromTokenType(TokenType token) {
    switch(token) {
      case TokenType.mod: return mod;
      case TokenType.pow: return pow;
      case TokenType.times: return times;
      case TokenType.div: return div;
      case TokenType.plus: return plus;
      case TokenType.minus: return minus;
      case TokenType.xor: return xor;
      case TokenType.and: return and;
      case TokenType.or: return or;
      case TokenType.l_and: return logicalAnd;
      case TokenType.l_or: return logicalOr;
      case TokenType.equals: return equals;
      case TokenType.notEquals: return notEquals;
      case TokenType.lt: return lt;
      case TokenType.lte: return lte;
      case TokenType.gt: return gt;
      case TokenType.gte: return gte;
      case TokenType.shl: return shl;
      case TokenType.shr: return shr;
      default: {
        return null;
      }
    }
  }
}

class BinaryExpressionContext extends ExpressionContext {
  final ExpressionContext left, right;
  final BinaryOp op;

  BinaryExpressionContext(this.left, this.op, this.right, FileSpan span,
      List<Comment> comments)
      : super(span, comments);

  String toString() => '$left ${op.rep} $right';
}

class ConditionalExpressionContext extends ExpressionContext {
  final ExpressionContext condition, ifTrue, ifFalse;

  ConditionalExpressionContext(this.condition, this.ifTrue, this.ifFalse,
      FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class TupleExpressionContext extends ExpressionContext {
  final List<ExpressionContext> expressions;

  TupleExpressionContext(
      this.expressions, FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class CallExpressionContext extends ExpressionContext {
  final ExpressionContext target;
  final List<ExpressionContext> arguments;

  CallExpressionContext(
      this.target, this.arguments, FileSpan span, List<Comment> comments)
      : super(span, comments);

  String toString() => '$target(${arguments.map((a) => a.toString()).join(', ')})';
}

class MemberExpressionContext extends ExpressionContext {
  final ExpressionContext target;
  final IdentifierContext identifier;

  MemberExpressionContext(
      this.target, this.identifier, FileSpan span, List<Comment> comments)
      : super(span, comments);
}
