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
  SimpleIdentifierContext(FileSpan span, List<Comment> comments)
      : super(span, comments);

  String get name => span.text;
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
}

class PrintExpressionContext extends ExpressionContext {
  final ExpressionContext expression;

  PrintExpressionContext(this.expression, FileSpan span, List<Comment> comments)
      : super(span, comments);
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

class BinaryExpressionContext extends ExpressionContext {
  final ExpressionContext left, right;
  final Token operator;

  BinaryExpressionContext(this.left, this.operator, this.right, FileSpan span,
      List<Comment> comments)
      : super(span, comments);
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
  final TupleExpressionContext arguments;

  CallExpressionContext(
      this.target, this.arguments, FileSpan span, List<Comment> comments)
      : super(span, comments);
}

class MemberExpressionContext extends ExpressionContext {
  final ExpressionContext target;
  final IdentifierContext identifier;

  MemberExpressionContext(
      this.target, this.identifier, FileSpan span, List<Comment> comments)
      : super(span, comments);
}
