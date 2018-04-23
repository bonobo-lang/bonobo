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
    final parts = <ExpressionChainPart>[];

    ExpressionChainPart prev;

    for (ExpressionChainPart part = _parseExpPart();
        part != null;
        part = _parseExpPart()) {
      precedence ??= part.precedence;
      if (part.precedence > precedence) {
        ExpressionContext exp = _parsePartsWithPrecedence(
            part.precedence,
            new ExpChainCtx(
                    prev.right.span.expand(part.span), [], prev.right, part)
                .right);
        part = new ExpressionChainPart(
            prev.span.expand(exp.span), [], prev.op, exp);
        prev = null;
      }

      if (prev != null) parts.add(prev);
      prev = part;
    }
    if (prev != null) parts.add(prev);

    if (parts.length == 0) return first;

    if (parts.length == 1)
      return new ExpChainCtx(
              first.span.expand(parts[0].span), [], first, parts[0])
          .right;

    prev = parts[parts.length - 2];
    ExpressionChainPart cur = parts.last;
    var op = prev.op;
    ExpressionContext exp = new ExpChainCtx(
            prev.right.span.expand(cur.span), [], prev.right, parts.last)
        .right;
    for (int i = parts.length - 2; i >= 1; i++) {
      prev = parts[i - 2];
      cur = parts[i - 1];
      exp = new ExpChainCtx(prev.right.span.expand(exp.span), [], prev.right,
              new ExpressionChainPart(op.span.expand(exp.span), [], op, exp))
          .right;
      op = prev.op;
    }
    exp = new ExpChainCtx(first.span.expand(exp.span), [], first,
            new ExpressionChainPart(op.span.expand(exp.span), [], op, exp))
        .right;
    return exp;
  }

  ExpressionChainPart _parseExpPart() {
    Token peek = state.peek();
    if (peek == null) return null;

    BinaryOperator op = BinaryOperator.fromTokenType(peek.type);
    if (op == null) return null;
    state.consume();

    var opCtx = new BinaryExpressionPartContext(peek.span, [], op);
    ExpressionContext exp = parseSingleExpression();
    if (exp == null) return null;
    return new ExpressionChainPart(peek.span.expand(exp.span), [], opCtx, exp);
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
            new PrefixOperatorContext(
                token.span, [], PrefixOperator.fromToken(token.type)),
            exp);
      case TokenType.lParen:
        return _parseParenExp();
      case TokenType.lSq:
        return _parseList();
      case TokenType.lCurly:
        return _parseMap();
      case TokenType.number:
        return parseNumberLiteral();
      case TokenType.string:
        state.consume();
        return new StringLiteralContext(token.span, []);
      case TokenType.identifier:
        return parseChainExp();
      default:
        return null;
    }
  }

  NumberLiteralContext parseNumberLiteral() {
    if (state.peek()?.type == TokenType.number)
      return new NumberLiteralContext(state.consume().span, []);
    return _parseHex();
  }

  NumberLiteralContext _parseHex() {
    if (state.peek()?.type == TokenType.hex) {
      return new HexLiteralContext(state.consume().span, []);
    }
    return null;
  }

  ExpressionContext _parseParenExp() {
    Token lParen = state.consume();
    ExpressionContext exp = parse();
    if (exp == null) return null;

    {
      Token decider = state.peek();
      if (decider == null) return null;

      // Tuple
      if (decider.type == TokenType.comma) {
        return _parseTuple(lParen, exp);
      }

      // Range
      if (decider.type == TokenType.colon) {
        return _parseRange(lParen, exp);
      }
    }

    Token rParen = state.nextToken(TokenType.rParen);
    if (rParen == null) return null;

    return exp; // TODO span the parenthesis
  }

  TupleExpressionContext _parseTuple(Token startTok, ExpressionContext first) {
    state.consume();

    final exps = <ExpressionContext>[first];

    for (ExpressionContext exp = parse(); exp != null; exp = parse()) {
      exps.add(exp);
      if (state.nextToken(TokenType.comma) == null) break;
    }

    Token rParen = state.nextToken(TokenType.rParen);
    if (rParen == null) return null;

    return new TupleExpressionContext(
        exps, startTok.span.expand(rParen.span), []);
  }

  ArrayLiteralContext _parseList() {
    Token lSq = state.nextToken(TokenType.lSq);

    final exps = <ExpressionContext>[];

    for (ExpressionContext exp = parse(); exp != null; exp = parse()) {
      exps.add(exp);
      if (state.nextToken(TokenType.comma) == null) break;
    }

    Token rParen = state.nextToken(TokenType.rParen);
    if (rParen == null) return null;

    return new ArrayLiteralContext(lSq.span.expand(rParen.span), [], exps);
  }

  ObjectLiteralContext _parseMap() {
    Token lCurly = state.nextToken(TokenType.lCurly);

    final keys = <ExpressionContext>[];
    final values = <ExpressionContext>[];

    for (ExpressionContext exp = parse(); exp != null; exp = parse()) {
      keys.add(exp);
      if (state.nextToken(TokenType.colon) == null) return null;
      exp = parse();
      if (exp == null) return null;
      values.add(exp);
      if (state.nextToken(TokenType.comma) == null) break;
    }

    Token rCurly = state.nextToken(TokenType.rCurly);
    if (rCurly == null) return null;

    return new ObjectLiteralContext(
        lCurly.span.expand(rCurly.span), [], keys, values);
  }

  RangeExpressionContext _parseRange(
      Token startTok, ExpressionContext startRange) {
    state.consume();

    ExpressionContext endRange = parse();
    if (endRange == null) return null;

    ExpressionContext step;
    if (state.peek()?.type == TokenType.colon) {
      step = parse();
      if (step == null) return null;
    }

    Token rParen = state.nextToken(TokenType.rParen);
    if (rParen == null) return null;

    return new RangeExpressionContext(
        startTok.span.expand(rParen.span), [], startRange, endRange, step);
  }

  CallIdChainExpPartCtx _parseCallParams() {
    final args = <ExpressionContext>[];

    Token lParen = state.nextToken(TokenType.lParen);
    var lastSpan = lParen?.span;

    if (lParen == null) return null;

    for (ExpressionContext exp = parse(); exp != null; exp = parse()) {
      args.add(exp);
      lastSpan = exp.span;
      if (state.nextToken(TokenType.comma) == null) break;
    }

    Token rParen = state.nextToken(TokenType.rParen);

    if (rParen == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing ')' after expression.", lastSpan));
      return null;
    }

    return new CallIdChainExpPartCtx(lParen.span.expand(rParen.span), [], args);
  }

  SubscriptIdChainExpPartCtx _parseSubscript() {
    final args = <ExpressionContext>[];

    Token lParen = state.nextToken(TokenType.lSq);

    for (ExpressionContext exp = parse(); exp != null; exp = parse()) {
      args.add(exp);
      if (state.nextToken(TokenType.comma) == null) break;
    }

    Token rParen = state.nextToken(TokenType.rSq);

    if (rParen == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing ']' after expression.", lParen.span));
      return null;
    }

    return new SubscriptIdChainExpPartCtx(
        lParen.span.expand(rParen.span), [], args);
  }

  ExpressionContext parseChainExp() {
    ExpressionContext target = state.parseIdentifier();

    if (target == null) return null;

    Token peek = state.peek();
    while (peek != null) {
      switch (peek.type) {
        case TokenType.dot:
          state.consume();
          SimpleIdentifierContext id = state.parseSimpleIdentifier();

          if (id == null) {
            state.errors.add(new BonoboError(BonoboErrorSeverity.error,
                "Missing identifier after '.'.", peek.span));
            return null;
          }

          target = new MemberExpressionContext(
              target, id, target.span.expand(peek.span).expand(id.span), []);
          break;
        case TokenType.lParen:
          var args = _parseCallParams();
          if (args == null) return null;
          target = _callExpression(target, args);
          break;
        /*
        TODO: SubscriptExpressionContext
        case TokenType.lSq:
          var sub = _parseSubscript();
          now = _parseSubscript();
          if (now == null) return null;
          break;
        */
        // TODO cascade operator?
        default:
          break;
      }
    }

    return target;
  }

  CallExpressionContext _callExpression(
      IdentifierContext target, CallIdChainExpPartCtx chain) {
    var tuple =
        new TupleExpressionContext(chain.args, chain.span, chain.comments);
    return new CallExpressionContext(
        target, tuple, target.span.expand(tuple.span), target.comments);
  }
}
