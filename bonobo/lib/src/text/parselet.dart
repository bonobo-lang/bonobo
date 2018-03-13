part of bonobo.src.text;

typedef ExpressionContext PrefixParselet(
    Parser parser, Token token, List<Comment> comments);

typedef ExpressionContext PostfixParselet(
    Parser parser, ExpressionContext left, Token token, List<Comment> comments);

class InfixParselet {
  final int precedence;

  final ExpressionContext Function(Parser parser, ExpressionContext left,
      Token token, List<Comment> comments) parse;

  const InfixParselet(this.precedence, this.parse);
}
