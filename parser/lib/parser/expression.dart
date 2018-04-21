part of 'parser.dart';

class ExpressionParser {
  final BonoboParseState state;

  ExpressionParser(this.state);

  ExpressionContext parse() {
    ExpressionContext first = _parseSingleExpression();
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
    BinaryOpCtx op = prev.op;
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

    BinaryOp op = BinaryOp.fromTokenType(peek.type);
    if (op == null) return null;
    state.consume();

    BinaryOpCtx opCtx = new BinaryOpCtx(peek.span, [], op);
    ExpressionContext exp = _parseSingleExpression();
    if (exp == null) return null;
    return new ExpChainPartCtx(peek.span.expand(exp.span), [], opCtx, exp);
  }

  ExpressionContext _parseSingleExpression() {
    Token token = state.peek();
    if (token == null) return null;

    switch (token.type) {
      case TokenType.minus:
      case TokenType.tilde:
      case TokenType.not:
        state.consume();
        ExpressionContext exp = _parseSingleExpression();
        if (exp == null) return null;
        return new PrefixExpCtx(
            token.span.expand(exp.span),
            [],
            new PrefixOpCtx(token.span, [], PrefixOp.fromToken(token.type)),
            exp);
      case TokenType.lParen:
        return _parseParenExp();
      case TokenType.lSq:
        return _parseList();
      case TokenType.lCurly:
        return _parseMap();
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

  TupleInitCtx _parseTuple(Token startTok, ExpressionContext first) {
    state.consume();

    final exps = <ExpressionContext>[first];

    for (ExpressionContext exp = parse(); exp != null; exp = parse()) {
      exps.add(exp);
      if (state.nextToken(TokenType.comma) == null) break;
    }

    Token rParen = state.nextToken(TokenType.rParen);
    if (rParen == null) return null;

    return new TupleInitCtx(startTok.span.expand(rParen.span), [], exps);
  }

  ListInitCtx _parseList() {
    Token lSq = state.nextToken(TokenType.lSq);

    final exps = <ExpressionContext>[];

    for (ExpressionContext exp = parse(); exp != null; exp = parse()) {
      exps.add(exp);
      if (state.nextToken(TokenType.comma) == null) break;
    }

    Token rParen = state.nextToken(TokenType.rParen);
    if (rParen == null) return null;

    return new ListInitCtx(lSq.span.expand(rParen.span), [], exps);
  }

  MapInitCtx _parseMap() {
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

    return new MapInitCtx(lCurly.span.expand(rCurly.span), [], keys, values);
  }

  RangeCtx _parseRange(Token startTok, ExpressionContext startRange) {
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

    return new RangeCtx(
        startTok.span.expand(rParen.span), [], startRange, endRange, step);
  }

  CallIdChainExpPartCtx _parseCallParams() {
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
    IdentifierContext id = state.nextId();

    final parts = <IdChainExpPartCtx>[];

    Token peek = state.peek();
    while (peek != null) {
      IdChainExpPartCtx now;
      switch (peek.type) {
        case TokenType.dot:
          state.consume();
          SimpleIdentifierContext id = state.nextSimpleId();
          if (id == null) return null;
          now = new MemberIdChainExpPartCtx(peek.span.expand(id.span), [], id);
          break;
        case TokenType.lParen:
          now = _parseCallParams();
          if (now == null) return null;
          break;
        case TokenType.lSq:
          now = _parseSubscript();
          if (now == null) return null;
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
