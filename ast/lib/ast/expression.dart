part of bonobo.src.ast;

class ExpressionContext extends AstNode {
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

class BinaryOp {
  final int value;

  final String rep;

  final String name;

  final int precedence;

  const BinaryOp._(this.value, this.rep, this.name, this.precedence);

  static const BinaryOp mod = const BinaryOp._(0, '%', 'mod', 10);

  static const BinaryOp pow = const BinaryOp._(1, '**', 'pow', 10);

  static const BinaryOp times = const BinaryOp._(2, '*', 'times', 10);

  static const BinaryOp div = const BinaryOp._(3, '/', 'div', 10);

  // TODO truncated div

  static const BinaryOp plus = const BinaryOp._(4, '+', 'plus', 8);

  static const BinaryOp minus = const BinaryOp._(5, '-', 'minus', 8);

  static const BinaryOp xor = const BinaryOp._(6, '^', 'xor', 8);

  static const BinaryOp and = const BinaryOp._(7, '&', 'and', 10);

  static const BinaryOp or = const BinaryOp._(8, '|', 'or', 8);

  static const BinaryOp logicalAnd =
      const BinaryOp._(9, '&&', 'logical and', 2);

  static const BinaryOp logicalOr = const BinaryOp._(10, '||', 'logical or', 4);

  static const BinaryOp equals = const BinaryOp._(11, '==', 'eq', 6);

  static const BinaryOp notEquals = const BinaryOp._(12, '!=', 'neq', 6);

  static const BinaryOp lt = const BinaryOp._(13, '<', 'lt', 6);

  static const BinaryOp lte = const BinaryOp._(14, '<=', 'lte', 6);

  static const BinaryOp gt = const BinaryOp._(15, '>', 'gt', 6);

  static const BinaryOp gte = const BinaryOp._(16, '>=', 'gte', 6);

  static const BinaryOp shl = const BinaryOp._(17, '<<', 'shl', 10);

  static const BinaryOp shr = const BinaryOp._(18, '>>', 'shr', 10);

  static BinaryOp fromTokenType(TokenType token) {
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

class BinaryOpCtx extends AstNode {
  final BinaryOp op;

  BinaryOpCtx(FileSpan span, List<Comment> comments, this.op)
      : super(span, comments);

  int get precedence => op.precedence;

  String toString() => op.rep;
}

class ExpChainPartCtx extends AstNode {
  final BinaryOpCtx op;
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

  BinaryOpCtx get op => rightPart.op;

  ExpressionContext get right => rightPart.right;

  String toString() => '($left $rightPart)';
}

class IdChainExpCtx extends ExpressionContext {
  final IdentifierContext target;
  final List<IdChainExpPartCtx> parts;

  IdChainExpCtx(FileSpan span, List<Comment> comments, this.target, this.parts)
      : super(span, comments);

  String toString() =>
      target.toString() + parts.join();
}

abstract class IdChainExpPartCtx implements AstNode {}

class CallIdChainExpPartCtx extends AstNode implements IdChainExpPartCtx {
  final List<ExpressionContext> args;

  CallIdChainExpPartCtx(FileSpan span, List<Comment> comments, this.args)
      : super(span, comments);

  String toString() => '(' + args.join(', ') +')';
}
