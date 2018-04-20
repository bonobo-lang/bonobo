part of bonobo.src.ast;

abstract class ExpressionContext extends AstNode {
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
  SimpleIdentifierContext(FileSpan span, List<Comment> comments)
      : super(span, comments);

  String get name => span.text;

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitSimpleIdentifier(this);
}

class NamespacedIdentifierContext extends IdentifierContext {
  final List<SimpleIdentifierContext> namespaces;
  final SimpleIdentifierContext symbol;

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
}

class PrintExpressionContext extends ExpressionContext {
  final ExpressionContext expression;

  PrintExpressionContext(this.expression, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitPrintExpression(this);
}

class ParenthesizedExpressionContext extends ExpressionContext {
  final ExpressionContext expression;

  ParenthesizedExpressionContext(
      this.expression, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  ExpressionContext get innermost => expression.innermost;

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitParenthesizedExpression(this);
}

class PrefixExpressionContext extends ExpressionContext {
  final Token operator;
  final ExpressionContext expression;

  PrefixExpressionContext(
      this.operator, this.expression, FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitPrefixExpression(this);
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

class AssignmentExpressionContext extends ExpressionContext {
  final ExpressionContext left, right;
  final Token operator;

  AssignmentExpressionContext(this.left, this.operator, this.right,
      FileSpan span, List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitAssignmentExpression(this);
}

class BinaryExpressionContext extends ExpressionContext {
  final ExpressionContext left, right;
  final Token operator;

  BinaryExpressionContext(this.left, this.operator, this.right, FileSpan span,
      List<Comment> comments)
      : super(span, comments);

  @override
  T accept<T>(BonoboAstVisitor<T> visitor) => visitor.visitBinaryExpression(this);
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
