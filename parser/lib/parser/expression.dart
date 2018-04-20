part of 'parser.dart';

class ExpressionParser {
  final BonoboParseState state;

  ExpressionParser(this.state);

  ExpressionContext parse(int precedence) {
    Token token = state.peek();
    if (token == null) return null;

    ExpressionContext left;

    switch (token.type) {
      case TokenType.minus:
        // TODO minux operator
        break;
      case TokenType.tilde:
        // TODO binary not operator
        break;
      case TokenType.not:
        // TODO logical not operator
        break;
      case TokenType.lParen:
        // TODO Tuple initialization expression
        break;
      case TokenType.number:
        state.consume();
        left = new NumberLiteralContext(token.span, []);
        break;
      case TokenType.string:
        Token t = state.consume();
        left = new StringLiteralContext(token.span, []);
        break;
      case TokenType.identifier:
        IdentifierContext id = state.nextId();
        switch (state.peek().type) {
          case TokenType.dot:
            // TODO: Support this logic for MemberExpression
            throw new UnimplementedError('Member expressions');
            break;
          case TokenType.lParen:
            List<ExpressionContext> args = parseCallParams();
            if (args == null) return null;
            left = new CallExpressionContext(
              id,
              args,
              args.length == 0 ? id.span : id.span.expand(args.last.span),
              [],
            );
            break;
          default:
            throw new UnimplementedError('Super cool features');
            break;
        }
        break;
      default:
        // TODO
        throw new UnimplementedError();
        break;
    }

    if(state.done) return left;

    while(state.peek().type == TokenType.lParen) {
      // TODO repeated calls
    }

    while (precedence < state.getPrecedence()) {
      Token token = state.consume();
      InfixParselet infix = _infixParselets[token.type];
      left = infix.parse(state, left, token, []);
    }

    return left;
  }

  List<ExpressionContext> parseCallParams() {
    final exps = <ExpressionContext>[];

    Token lParen = state.nextToken(TokenType.lParen);

    // The parentheses make it OK to include a tuple in a variable declaration.
    //
    // So `inVariableDeclaration` will be `false`.

    for (ExpressionContext exp = parse(0); exp != null; exp = parse(0)) {
      exps.add(exp);

      if (state.nextToken(TokenType.comma) == null) break;
    }

    Token rParen = state.nextToken(TokenType.rParen);

    if (rParen == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing ')' after expression.", lParen.span));
      return null;
    }

    return exps;
  }
}
