part of 'parser.dart';

class ExpressionParser {
  final BonoboParseState state;

  ExpressionParser(this.state);

  ExpressionContext parse(int precedence, bool inVariableDeclaration) {
    //var comments = parseComments();
    Token token = state.peek();

    if (token == null) return null;

    ExpressionContext left;
    PrefixParselet prefix = _prefixParselets[token.type];

    if (prefix == null) {
      /*
      errors.add(new BonoboError(BonoboErrorSeverity.error,
          'Expected expression, found "${token.span.text}".', token.span));
          */

      left = state.lookAhead(state.nextId);
      if (left == null) return null;
    } else {
      state.consume();
      left = prefix(state, token, [], false);
    }

    while (precedence < state.getPrecedence() && left != null) {
      if (inVariableDeclaration && state.peek()?.type == TokenType.comma)
        return left;
      token = state.consume();

      InfixParselet infix = _infixParselets[token.type];
      left = infix.parse(state, left, token, [], inVariableDeclaration);
    }

    // TODO: Support this logic for MemberExpression
    if (left is SimpleIdentifierContext) {
      // See https://github.com/bonobo-lang/bonobo/issues/9.
      var arg = parse(0, false);

      if (arg != null) {
        var span = left.span.expand(arg.span);

        if (arg.innermost is! TupleExpressionContext) {
          left = new CallExpressionContext(
            left,
            new TupleExpressionContext(
              [arg],
              arg.span,
              [],
            ),
            span,
            [],
          );
        } else {
          left = new CallExpressionContext(
            left,
            arg.innermost,
            span,
            [],
          );
        }
      }
    }

    return left;
  }
}
