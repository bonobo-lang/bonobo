part of 'parser.dart';

class FunctionParser {
  final Parser parser;

  FunctionParser(this.parser);

  FunctionContext parse({List<Comment> comments}) {
    FileSpan startSpan = parser.peek().span;

    if (parser.nextToken(TokenType.fn) == null) return null;

    bool isHidden = parser.nextToken(TokenType.hide_) != null;

    // TODO constexpr modifier

    SimpleIdentifierContext name = parser.parseSimpleIdentifier();

    if (name == null) {
      parser.errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Expected function name.",
          parser.peek().span /* TODO What if there is no token? */));
      return null;
    }

    if (parser.peek().type == TokenType.identifier) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Invalid function modifier ${name.name}.", name.span));
      return null;
    }

    FunctionSignatureContext signature = parseSignature();

    var body = parseBody();

    if (body == null) {
      parser.errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing function body.", signature.span));
      return null;
    }

    return new FunctionContext(
        name, signature, body, startSpan.expand(body.span), comments,
        isHidden: isHidden);
  }

  FunctionSignatureContext parseSignature() {
    Token peek = parser.peek();
    if (peek == null) return null;
    FileSpan span = peek.span;

    ParameterListContext parameterList;
    // Parameter list
    if (peek.type == TokenType.lParen) {
      parameterList = parseParameterList();
      if (parameterList == null) return null;
      span = span.expand(parameterList.span);
      peek = parser.peek();
    }

    // Return type
    TypeContext returnType;
    if (peek.type == TokenType.colon) {
      parser.consume();
      returnType = parser.typeParser.parse(comments: parser.parseComments());
      if (returnType == null) return null;
      span = span.expand(returnType.span);
    }

    return new FunctionSignatureContext(parameterList, returnType, span, []);
  }

  ParameterListContext parseParameterList() {
    Token lParen = parser.nextToken(TokenType.lParen);
    if (lParen == null) return null;

    var span = lParen.span, lastSpan = span;

    var parameters = <ParameterContext>[];
    for (ParameterContext parameter = parseParameter();
        parameter != null;
        parameter = parseParameter()) {
      parameters.add(parameter);
      span = span.expand(lastSpan = parameter.span);
      if (parser.nextToken(TokenType.comma) == null) break;
    }

    Token rParen = parser.nextToken(TokenType.rParen);

    if (rParen == null) {
      parser.errors.add(
          new BonoboError(BonoboErrorSeverity.error, "Missing ')'.", lastSpan));
      return null;
    }

    span = span.expand(rParen.span);

    return new ParameterListContext(span, [], parameters);
  }

  ParameterContext parseParameter() {
    SimpleIdentifierContext id = parser.parseSimpleIdentifier();
    if (id == null) return null;

    FileSpan span = id.span;
    Token colon = parser.nextToken(TokenType.colon);

    if (colon == null) return new ParameterContext(id, null, span, []);

    TypeContext type = parser.typeParser.parse(comments: parser.parseComments());
    if (type == null) {
      parser.errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing type after ':'.", colon.span));
      return null;
    }

    span = span.expand(type.span);

    return new ParameterContext(id, type, span, []);
  }

  FunctionBodyContext parseBody() {
    Token decider = parser.peek();

    if (decider.type == TokenType.arrow) return parseLambdaBody();
    if (decider.type == TokenType.lCurly) return parseBlockFunctionBody();

    parser.errors.add(new BonoboError(
        BonoboErrorSeverity.error, "Function body expected.", decider.span));
    return null;
  }

  ExpressionFunctionBodyContext parseLambdaBody() {
    Token arrow = parser.nextToken(TokenType.arrow);
    if (arrow == null) return null;

    var exp = parser.expressionParser.parse(0, comments: parser.parseComments());

    if (exp == null) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression after '=>'.", arrow.span));
      return null;
    }

    return new ExpressionFunctionBodyContext(arrow.span.expand(exp.span), [], exp);
  }

  BlockFunctionBodyContext parseBlockFunctionBody() {
    var block = parseBlock();
    return block == null ? null : new BlockFunctionBodyContext(block);
  }

  BlockContext parseBlock() {
    Token lCurly = parser.nextToken(TokenType.lCurly);
    if (lCurly == null) return null;

    FileSpan lastSpan = lCurly.span;

    var statements = <StatementContext>[];

    for (StatementContext statement = parser.statementParser.parse(comments: parser.parseComments());
        statement != null;
        statement = parser.statementParser.parse(comments: parser.parseComments())) {
      statements.add(statement);
      lastSpan = statement.span;
    }

    Token rCurly = parser.consume();

    if (rCurly?.type != TokenType.rCurly) {
      parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing '}' in function body.", lastSpan));
      return null;
    }

    return new BlockContext(statements, lCurly.span.expand(rCurly.span), []);
  }
}
