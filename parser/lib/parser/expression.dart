part of 'parser.dart';

class ExpressionParser {
  final Parser state;

  ExpressionParser(this.state);

  ExpressionContext parse() {
    ExpressionContext first = parseSingleExpression();
    if (first == null) return null;

    return _parsePartsWithPrecedence(null, first);
  }

  ExpressionContext _parsePartsWithPrecedence(
      int precedence, ExpressionContext first) {
    final parts = <ExpChainPartCtx>[];

    ExpChainPartCtx prev;

    for (ExpChainPartCtx part = _parseExpPart();
        part != null;
        part = _parseExpPart()) {
      precedence ??= part.precedence;
      if (part.precedence > precedence) {
        ExpressionContext exp = _parsePartsWithPrecedence(
            part.precedence,
            new ExpChainCtx(
                prev.right.span.expand(part.span), [], prev.right, part));
        part =
            new ExpChainPartCtx(prev.span.expand(exp.span), [], prev.op, exp);
        prev = null;
      }

      if (prev != null) parts.add(prev);
      prev = part;
    }
    if (prev != null) parts.add(prev);

    if (parts.length == 0) return first;

    if (parts.length == 1)
      return new ExpChainCtx(
          first.span.expand(parts[0].span), [], first, parts[0]);

    prev = parts[parts.length - 2];
    ExpChainPartCtx cur = parts.last;
    BinaryExpressionContext op = prev.op;
    ExpressionContext exp = new ExpChainCtx(
        prev.right.span.expand(cur.span), [], prev.right, parts.last);
    for (int i = parts.length - 2; i >= 1; i++) {
      prev = parts[i - 2];
      cur = parts[i - 1];
      exp = new ExpChainCtx(prev.right.span.expand(exp.span), [], prev.right,
          new ExpChainPartCtx(op.span.expand(exp.span), [], op, exp));
      op = prev.op;
    }
    exp = new ExpChainCtx(first.span.expand(exp.span), [], first,
        new ExpChainPartCtx(op.span.expand(exp.span), [], op, exp));
    return exp;
  }

  ExpChainPartCtx _parseExpPart() {
    Token peek = state.peek();
    if (peek == null) return null;

    BinaryOperator op = BinaryOperator.fromTokenType(peek.type);
    if (op == null) return null;
    state.consume();

    //var opCtx = new BinaryExpressionContext(span, [], left, right, op);
    BinaryExpressionContext opCtx = new BinaryExpressionContext(peek.span, [], op);
    ExpressionContext exp = parseSingleExpression();
    if (exp == null) return null;
    return new ExpChainPartCtx(peek.span.expand(exp.span), [], opCtx, exp);
  }

  ExpressionContext parseSingleExpression() {
    Token token = state.peek();
    if (token == null) return null;

    switch (token.type) {
      case TokenType.minus:
      case TokenType.tilde:
      case TokenType.not:
        state.consume();
        ExpressionContext exp = parseSingleExpression();
        if (exp == null) return null;
        return new PrefixExpressionContext(
            token.span.expand(exp.span),
            [],
            new PrefixOperatorContext(token.span, [], PrefixOperator.fromToken(token.type)),
            exp);
      case TokenType.lParen:
        state.consume();
        ExpressionContext exp = parse();
        // TODO Sub-expression
        // TODO Tuple initialization expression
        throw new UnimplementedError('Sub-expressions');
        Token rParen = state.nextToken(TokenType.rParen);
        if (rParen == null) return null;
        // TODO
        break;
      case TokenType.lSq:
        // TODO List initialization expression
        break;
      case TokenType.lCurly:
        // TODO Map initialization expression
        break;
      case TokenType.number:
        state.consume();
        return new NumberLiteralContext(token.span, []);
      case TokenType.string:
        state.consume();
        return new StringLiteralContext(token.span, []);
      case TokenType.identifier:
        return parseChainExp();
      default:
        return null;
    }

    return null;
  }

  CallIdChainExpPartCtx parseCallParams() {
    final args = <ExpressionContext>[];

    Token lParen = state.nextToken(TokenType.lParen);

    for (ExpressionContext exp = parse(); exp != null; exp = parse()) {
      args.add(exp);
      if (state.nextToken(TokenType.comma) == null) break;
    }

    Token rParen = state.nextToken(TokenType.rParen);

    if (rParen == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing ')' after expression.", lParen.span));
      return null;
    }

    return new CallIdChainExpPartCtx(lParen.span.expand(rParen.span), [], args);
  }

  ExpressionContext parseChainExp() {
    IdentifierContext id = state.parseIdentifier();

    final parts = <IdChainExpPartCtx>[];

    Token peek = state.peek();
    while (peek != null) {
      IdChainExpPartCtx now;
      switch (peek.type) {
        case TokenType.dot:
          // TODO: Support this logic for MemberExpression
          throw new UnimplementedError('Member expressions');
          break;
        case TokenType.lParen:
          now = parseCallParams();
          if (now == null) return null;
          break;
        case TokenType.lSq:
          // TODO: Support this logic for subscript
          throw new UnimplementedError('Subscript');
          break;
        // TODO cascade operator?
        default:
          break;
      }
      if (now == null) break;
      parts.add(now);
      peek = state.peek();
    }

    if (parts.length == 0) return id;

    return new IdChainExpCtx(id.span.expand(parts.last.span), [], id, parts);
  }
}
