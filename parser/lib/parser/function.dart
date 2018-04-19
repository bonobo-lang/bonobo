part of 'parser.dart';

class FunctionParser {
  final BonoboParseState state;

  FunctionParser(this.state);

  FunctionContext parse({List<Comment> comments}) {
    // TODO use better way to compute spans
    FileSpan span = state.peek().span;

    if (state.nextToken(TokenType.func) == null) return null;

    bool isPub = state.nextToken(TokenType.pub) != null;

    // TODO constexpr

    SimpleIdentifierContext name = state.nextSimpleId();

    if (name == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Expected function name.",
          state.peek().span /* What if there is no token? */));
      return null;
    }

    span = span == null ? span : span.expand(name.span);
    FunctionSignatureContext signature = parseSignature(name.span);

    span = span.expand(signature.span);
    var body = parseBody();

    if (body == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing function body.", signature.span));
      return null;
    }

    return new FunctionContext(
        name, signature, body, span.expand(body.span), comments,
        isPub: isPub);
  }

  FunctionSignatureContext parseSignature(FileSpan currentSpan) {
    var parameterList = parseParameterList();
    var span = parameterList?.span, colon;
    TypeContext returnType;

    if ((colon = state.nextToken(TokenType.colon)) != null) {
      span = span == null ? colon.span : span.expand(colon.span);

      if ((returnType = state.nextType()) == null) {
        state.errors.add(new BonoboError(
            BonoboErrorSeverity.error, "Missing type after ':'.", colon.span));
      } else
        span = span.expand(returnType.span);
    }

    return new FunctionSignatureContext(
        parameterList, returnType, span ?? currentSpan, []);
  }

  ParameterListContext parseParameterList() {
    var closedParen = state.nextToken(TokenType.parentheses);
    if (closedParen != null)
      return new ParameterListContext([], closedParen.span, []);

    Token lParen = state.nextToken(TokenType.lParen);
    if (lParen == null) return null;

    var span = lParen.span, lastSpan = span;

    var parameters = <ParameterContext>[];
    for (ParameterContext parameter = parseParameter();
        parameter != null;
        parameter = parseParameter()) {
      parameters.add(parameter);
      span = span.expand(lastSpan = parameter.span);
      if (state.nextToken(TokenType.comma) == null) break;
    }

    Token rParen = state.nextToken(TokenType.rParen);

    if (rParen == null) {
      state.errors.add(
          new BonoboError(BonoboErrorSeverity.error, "Missing ')'.", lastSpan));
      return null;
    }

    span = span.expand(rParen.span);

    return new ParameterListContext(parameters, span, []);
  }

  ParameterContext parseParameter() {
    SimpleIdentifierContext id = state.nextId();
    if (id == null) return null;

    var span = id.span;
    Token colon = state.nextToken(TokenType.colon);

    if (colon == null) {
      return new ParameterContext(id, null, span, []);
    }

    TypeContext type = state.nextType();

    span = span.expand(colon.span);

    if (type == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing type after ':'.", colon.span));
    } else
      span = span.expand(type.span);

    return new ParameterContext(id, type, span, []);
  }

  FunctionBodyContext parseBody() {
    Token decider = state.peek();

    if (decider.type == TokenType.arrow) return parseLambdaBody();

    if (state.nextToken(TokenType.lCurly) != null) {
      // TODO return parseBlockFunctionBody();
      throw new UnimplementedError('Block functions');
    }

    throw new Exception('Add error!');
  }

  LambdaFunctionBodyContext parseLambdaBody() {
    Token arrow = state.nextToken(TokenType.arrow);
    if (arrow == null) return null;

    ExpressionContext expression = new ExpressionParser(state).parse(0, false);

    if (expression == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after '=>'.", arrow.span));
      return null;
    }

    return new LambdaFunctionBodyContext(
        expression, arrow.span.expand(expression.span), []);
  }
}

class IdentifierParser {
  final ParserState state;

  IdentifierParser(this.state);

  IdentifierContext parse() {
    var id = state.nextToken(TokenType.identifier);

    if (id == null) return null;

    var identifiers = <Token>[id];
    var span = id.span;

    while (state.peek()?.type == TokenType.double_colon) {
      var doubleColon = state.nextToken(TokenType.double_colon);
      span = span.expand(doubleColon.span);

      if (state.peek()?.type == TokenType.identifier) {
        id = state.consume();
      } else {
        id = null;
      }

      if (id == null) {
        if (span == null) return null;
        state.errors.add(new BonoboError(
            BonoboErrorSeverity.error, "Missing identifier after '::'.", span));
        return null;
      } else {
        span = span.expand(id.span);
        identifiers.add(id);
      }
    }

    if (identifiers.length == 1) {
      return new SimpleIdentifierContext(span, []);
    }

    var parts = identifiers
        .take(identifiers.length - 1)
        .map((t) => new SimpleIdentifierContext(t.span, []))
        .toList();
    return new NamespacedIdentifierContext(parts,
        new SimpleIdentifierContext(identifiers.last.span, []), span, []);
  }
}
