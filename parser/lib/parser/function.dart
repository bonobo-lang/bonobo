part of 'parser.dart';

class FunctionParser {
  final Parser state;

  FunctionParser(this.state);

  FunctionContext parse({List<Comment> comments}) {
    FileSpan startSpan = state.peek().span;

    if (state.nextToken(TokenType.fn) == null) return null;

    bool isHidden = state.nextToken(TokenType.hide_) != null;

    // TODO constexpr modifier

    SimpleIdentifierContext name = state.parseSimpleIdentifier();

    if (name == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Expected function name.",
          state.peek().span /* TODO What if there is no token? */));
      return null;
    }

    if (state.peek().type == TokenType.identifier) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Invalid function modifier ${name.name}.", name.span));
      return null;
    }

    FunctionSignatureContext signature = parseSignature();

    var body = parseBody();

    if (body == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing function body.", signature.span));
      return null;
    }

    return new FunctionContext(
        name, signature, body, startSpan.expand(body.span), comments,
        isHidden: isHidden);
  }

  FunctionSignatureContext parseSignature() {
    Token peek = state.peek();
    if (peek == null) return null;
    FileSpan span = peek.span;

    ParameterListContext parameterList;
    // Parameter list
    if (peek.type == TokenType.lParen) {
      parameterList = parseParameterList();
      if (parameterList == null) return null;
      span = span.expand(parameterList.span);
      peek = state.peek();
    }

    // Return type
    TypeContext returnType;
    if (peek.type == TokenType.colon) {
      state.consume();
      returnType = state.typeParser.parse(comments: state.parseComments());
      if (returnType == null) return null;
      span = span.expand(returnType.span);
    }

    return new FunctionSignatureContext(parameterList, returnType, span, []);
  }

  ParameterListContext parseParameterList() {
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

    return new ParameterListContext(span, [], parameters);
  }

  ParameterContext parseParameter() {
    SimpleIdentifierContext id = state.parseSimpleIdentifier();
    if (id == null) return null;

    FileSpan span = id.span;
    Token colon = state.nextToken(TokenType.colon);

    if (colon == null) return new ParameterContext(id, null, span, []);

    TypeContext type = state.typeParser.parse(comments: state.parseComments());
    if (type == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing type after ':'.", colon.span));
      return null;
    }

    span = span.expand(type.span);

    return new ParameterContext(id, type, span, []);
  }

  FunctionBodyContext parseBody() {
    Token decider = state.peek();

    if (decider.type == TokenType.arrow) return parseLambdaBody();
    if (decider.type == TokenType.lCurly) return parseBlockFunctionBody();

    state.errors.add(new BonoboError(
        BonoboErrorSeverity.error, "Function body expected.", decider.span));
    return null;
  }

  LambdaFunctionBodyContext parseLambdaBody() {
    Token arrow = state.nextToken(TokenType.arrow);
    if (arrow == null) return null;

    var exp = state.parseExpression();

    if (exp == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after '=>'.", arrow.span));
      return null;
    }

    return new LambdaFunctionBodyContext(arrow.span.expand(exp.span), [], exp);
  }

  BlockFunctionBodyContext parseBlockFunctionBody() {
    var block = parseBlock();
    return block == null ? null : new BlockFunctionBodyContext(block);
  }

  BlockContext parseBlock() {
    Token lCurly = state.nextToken(TokenType.lCurly);
    if (lCurly == null) return null;

    FileSpan lastSpan = lCurly.span;

    var statements = <StatementContext>[];

    for (StatementContext statement = state.parseStatement();
        statement != null;
        statement = state.parseStatement()) {
      statements.add(statement);
      lastSpan = statement.span;
    }

    Token rCurly = state.consume();

    if (rCurly?.type != TokenType.rCurly) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing '}' in function body.", lastSpan));
      return null;
    }

    return new BlockContext(statements, lCurly.span.expand(rCurly.span), []);
  }
}
