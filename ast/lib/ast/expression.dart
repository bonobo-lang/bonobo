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
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitSimpleIdentifier(this);

  String toString() => name;
}

class NamespacedIdentifierContext extends IdentifierContext {
  final List<SimpleIdentifierContext> namespaces;
  final IdentifierContext symbol;

  NamespacedIdentifierContext(
      this.namespaces, this.symbol, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitNamespacedIdentifier(this);

  String toString() {
    var sb = new StringBuffer();
    sb.write(namespaces.join('::'));
    sb.write(symbol);
    return sb.toString();
  }
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

class PrefixOperator {
  final int value;

  final String rep;

  const PrefixOperator(this.value, this.rep);

  static const PrefixOperator minus = const PrefixOperator(0, '-');

  static const PrefixOperator plus = const PrefixOperator(2, '-');

  static const PrefixOperator complement = const PrefixOperator(3, '~');

  static const PrefixOperator not = const PrefixOperator(4, '!');

  static Map<TokenType, PrefixOperator> _map = const {
    TokenType.plus: plus,
    TokenType.minus: minus,
    TokenType.tilde: complement,
    TokenType.not: not,
  };

  static PrefixOperator fromToken(TokenType tok) => _map[tok];
}

class PrefixOperatorContext {
  final FileSpan span;
  final List<Comment> comments;
  final PrefixOperator op;

  PrefixOperatorContext(this.span, this.comments, this.op);

  String toString() => op.rep;
}

class PrefixExpressionContext extends ExpressionContext {
  final PrefixOperatorContext op;
  final ExpressionContext expression;

  PrefixExpressionContext(
      FileSpan span, List<Comment> comments, this.op, this.expression)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitPrefixExpression(this);

  String toString() => '$op$expression';
}

class BinaryOperator {
  final int value;

  final String rep;

  final String name;

  final int precedence;

  const BinaryOperator._(this.value, this.rep, this.name, this.precedence);

  static const BinaryOperator mod = const BinaryOperator._(0, '%', 'mod', 10);

  static const BinaryOperator pow = const BinaryOperator._(1, '**', 'pow', 10);

  static const BinaryOperator times =
      const BinaryOperator._(2, '*', 'times', 10);

  static const BinaryOperator div = const BinaryOperator._(3, '/', 'div', 10);

  // TODO truncated div

  static const BinaryOperator plus = const BinaryOperator._(4, '+', 'plus', 8);

  static const BinaryOperator minus =
      const BinaryOperator._(5, '-', 'minus', 8);

  static const BinaryOperator xor = const BinaryOperator._(6, '^', 'xor', 8);

  static const BinaryOperator and = const BinaryOperator._(7, '&', 'and', 10);

  static const BinaryOperator or = const BinaryOperator._(8, '|', 'or', 8);

  static const BinaryOperator logicalAnd =
      const BinaryOperator._(9, '&&', 'logical and', 2);

  static const BinaryOperator logicalOr =
      const BinaryOperator._(10, '||', 'logical or', 4);

  static const BinaryOperator equals =
      const BinaryOperator._(11, '==', 'eq', 6);

  static const BinaryOperator notEquals =
      const BinaryOperator._(12, '!=', 'neq', 6);

  static const BinaryOperator lt = const BinaryOperator._(13, '<', 'lt', 6);

  static const BinaryOperator lte = const BinaryOperator._(14, '<=', 'lte', 6);

  static const BinaryOperator gt = const BinaryOperator._(15, '>', 'gt', 6);

  static const BinaryOperator gte = const BinaryOperator._(16, '>=', 'gte', 6);

  static const BinaryOperator shl = const BinaryOperator._(17, '<<', 'shl', 10);

  static const BinaryOperator shr = const BinaryOperator._(18, '>>', 'shr', 10);

  static const Map<TokenType, BinaryOperator> _map = const {
    TokenType.mod: mod,
    TokenType.pow: pow,
    TokenType.times: times,
    TokenType.div: div,
    TokenType.plus: plus,
    TokenType.minus: minus,
    TokenType.xor: xor,
    TokenType.and: and,
    TokenType.or: or,
    TokenType.l_and: logicalAnd,
    TokenType.l_or: logicalOr,
    TokenType.equals: equals,
    TokenType.notEquals: notEquals,
    TokenType.lt: lt,
    TokenType.lte: lte,
    TokenType.gt: gt,
    TokenType.gte: gte,
    TokenType.shl: shl,
    TokenType.shr: shr,
  };

  static BinaryOperator fromTokenType(TokenType token) => _map[token];
}

class BinaryOperatorContext {
  final FileSpan span;
  final List<Comment> comments;
  final BinaryOperator op;

  BinaryOperatorContext(this.span, this.comments, this.op);

  int get precedence => op.precedence;

  String toString() => op.rep;
}

class BinaryExpressionPartContext {
  final FileSpan span;
  final List<Comment> comments;
  final BinaryOperatorContext op;
  final ExpressionContext right;

  BinaryExpressionPartContext(this.span, this.comments, this.op, this.right);

  int get precedence => op.precedence;

  String toString() => '${op.op.rep} $right';
}

class BinaryExpressionContext extends ExpressionContext {
  final ExpressionContext left;
  final BinaryExpressionPartContext rightPart;

  BinaryExpressionContext(
      FileSpan span, List<Comment> comments, this.left, this.rightPart)
      : super(span, comments);

  BinaryOperatorContext get op => rightPart.op;

  ExpressionContext get right => rightPart.right;

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitBinaryExpression(this);

  String toString() => '($left $rightPart)';
}

class IdentifierChainExpressionContext extends ExpressionContext {
  final IdentifierContext target;
  final List<IdentifierChainExpressionPartContext> parts;

  IdentifierChainExpressionContext(
      FileSpan span, List<Comment> comments, this.target, this.parts)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) =>
      visitor.visitIdentifierChainExpression(this);

  String toString() => target.toString() + parts.join();
}

abstract class IdentifierChainExpressionPartContext {
  FileSpan get span;
  List<Comment> get comments;
}

class IdentifierChainExpressionCallPartContext
    implements IdentifierChainExpressionPartContext {
  final FileSpan span;
  final List<Comment> comments;
  final List<ExpressionContext> args;

  IdentifierChainExpressionCallPartContext(this.span, this.comments, this.args);

  String toString() => '(' + args.join(', ') + ')';
}

class IdentifierChainExpressionMemberPartContext
    implements IdentifierChainExpressionPartContext {
  final FileSpan span;
  final List<Comment> comments;
  final SimpleIdentifierContext member;

  IdentifierChainExpressionMemberPartContext(
      this.span, this.comments, this.member);

  String get name => member.name;

  String toString() => '.$name';
}

class IdentifierChainExpressionSubscriptPartContext
    implements IdentifierChainExpressionPartContext {
  final FileSpan span;
  final List<Comment> comments;
  final List<ExpressionContext> indices;

  IdentifierChainExpressionSubscriptPartContext(
      this.span, this.comments, this.indices);

  String toString() => '(' + indices.join(':') + ')';
}

class ObjectLiteralContext extends ExpressionContext {
  final List<ExpressionContext> items;

  ObjectLiteralContext(FileSpan span, List<Comment> comments, this.items)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitTupleLiteral(this);

  String toString() => '(' + items.join(', ') + ')';
}

class ArrayLiteralContext extends ExpressionContext {
  final List<ExpressionContext> items;

  ArrayLiteralContext(FileSpan span, List<Comment> comments, this.items)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitArrayLiteral(this);
}

class MapLiteralContext extends ExpressionContext {
  final List<ExpressionContext> keys;
  final List<ExpressionContext> values;

  MapLiteralContext(
      FileSpan span, List<Comment> comments, this.keys, this.values)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitMapLiteral(this);
}

class RangeLiteralContext extends ExpressionContext {
  final ExpressionContext start;
  final ExpressionContext end;
  final ExpressionContext step;

  RangeLiteralContext(
      FileSpan span, List<Comment> comments, this.start, this.end, this.step)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitRangeLiteral(this);
}
