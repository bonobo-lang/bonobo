part of 'parser.dart';

final Map<TokenType, InfixParselet<ExpressionContext>> _infixParselets =
    createInfixParselets();

Map<TokenType, InfixParselet> createInfixParselets() {
  int precedence = 1;

  var infixParselets = <TokenType, InfixParselet>{};

  addBinary(List<TokenType> types) {
    var p = precedence++;
    for (var type in types) {
      infixParselets[type] = new BinaryParselet(p);
    }
  }

  addBinary([TokenType.assign]);

  // TODO: Tern
  infixParselets[TokenType.question] =
      new InfixParselet(precedence++, (parser, left, token, comments) {
    parser.errors.add(new BonoboError(BonoboErrorSeverity.warning,
        'The conditional operator is not supported... YET', token.span));
    return null;
  });

  // TODO: B_OR
  addBinary([TokenType.l_or]);

  // TODO: B_AND
  addBinary([TokenType.l_and]);

  // TODO: OR
  addBinary([TokenType.or]);

  // TODO: AND
  addBinary([TokenType.and]);

  // TODO: B_EQU, B_NOT_EQU
  addBinary([TokenType.equals, TokenType.notEquals]);

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
  infixParselets[TokenType.dot] =
      new InfixParselet(precedence++, (parser, left, token, comments) {
    var identifier = parser.nextSimpleId();

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
