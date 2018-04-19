part of bonobo.src.text;

final Map<TokenType, InfixParselet> _infixParselets = createInfixParselets();

Map<TokenType, InfixParselet> createInfixParselets() {
  int precedence = 1;

  var infixParselets = {
    // Parse tuples
    TokenType.comma: new InfixParselet(precedence++,
        (parser, left, token, comments, inVariableDeclaration) {
      if (inVariableDeclaration) {
        return left;
      }

      var span = left.span.expand(token.span);
      var right = parser.parseExpression(0, inVariableDeclaration).innermost;

      if (right == null) {
        parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
            "Missing expression after ','", token.span));
        return null;
      }

      span = span.expand(right.span);

      if (right is TupleExpressionContext) {
        return new TupleExpressionContext(
          []
            ..add(left)
            ..addAll(right.expressions),
          span,
          []..addAll(left.comments)..addAll(comments),
        );
      }

      return new TupleExpressionContext([left, right], span, comments);
    }),

    // Parse arg-less calls
    TokenType.parentheses: new InfixParselet(precedence++,
        (parser, left, token, comments, inVariableDeclaration) {
      return new CallExpressionContext(
        left,
        new TupleExpressionContext([], token.span, []),
        left.span.expand(token.span),
        []..addAll(left.comments)..addAll(comments),
      );
    }),
  };

  addBinary(List<TokenType> types) {
    var p = precedence++;
    for (var type in types) {
      infixParselets[type] = new BinaryParselet(p);
    }
  }

  addBinary([TokenType.equals]);

  // TODO: Tern
  infixParselets[TokenType.question] = new InfixParselet(precedence++,
      (parser, left, token, comments, inVariableDeclaration) {
    parser.errors.add(new BonoboError(BonoboErrorSeverity.warning,
        'The conditional operator is not supported... YET', token.span));
    return null;
  });

  // TODO: B_OR
  addBinary([TokenType.b_or]);

  // TODO: B_AND
  addBinary([TokenType.b_and]);

  // TODO: OR
  addBinary([TokenType.or]);

  // TODO: AND
  addBinary([TokenType.and]);

  // TODO: B_EQU, B_NOT_EQU
  addBinary([TokenType.b_equals, TokenType.b_not_equals]);

  // TODO: LT, LTE, GT, GTE
  addBinary([
    TokenType.lt,
    TokenType.lte,
    TokenType.gt,
    TokenType.gte,
  ]);

  // TODO: SHL, SHR
  addBinary([TokenType.shl, TokenType.shr]);

  // TODO: +, -
  addBinary([TokenType.plus, TokenType.minus]);

  // TODO: *, /, %
  addBinary([TokenType.times, TokenType.div, TokenType.mod]);

  // TODO: **
  addBinary([TokenType.pow]);

  // TODO: [], .
  infixParselets[TokenType.dot] = new InfixParselet(precedence++,
      (parser, left, token, comments, inVariableDeclaration) {
    var identifier = parser.parseSimpleIdentifier();

    if (identifier == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after '.'.", token.span));
      return null;
    }

    return new MemberExpressionContext(
      left,
      identifier,
      left.span.expand(token.span).expand(identifier.span),
      comments,
    );
  });
  return infixParselets;
}
