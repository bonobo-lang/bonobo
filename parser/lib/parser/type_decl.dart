part of 'parser.dart';

class TypeDeclarationParser {
  final Parser state;

  TypeDeclarationParser(this.state);

  TypeDeclarationContext parse() {
    FileSpan startSpan = state.peek().span;
    FileSpan lastSpan = startSpan;

    if (state.nextToken(TokenType.type) == null) return null;

    bool isPriv = state.nextToken(TokenType.hide_) != null;

    // TODO final modifier

    SimpleIdentifierContext name = state.parseSimpleIdentifier();

    if (name == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Expected class name.",
          state.peek().span /* TODO What if there is no token? */));
      return null;
    }
    lastSpan = name.span;

    // Optional assign
    state.nextToken(TokenType.assign);

    Token peek = state.peek();

    if (peek.type == TokenType.implements) {
      // TODO parse implements clause
      throw new UnimplementedError('implements');
      // TODO update lastSpan
      peek = state.peek();
    }

    if (peek.type == TokenType.implements) {
      // TODO parse mixes clause
      throw new UnimplementedError('mixes');
      // TODO update lastSpan
      peek = state.peek();
    }

    final fields = <VariableDeclarationStatementContext>[];
    final methods = <FunctionContext>[];

    peek = state.nextToken(TokenType.lParen);
    if (peek != null) {
<<<<<<< HEAD
      switch (state.peek().type) {
        case TokenType.let:
        case TokenType.var_:
        case TokenType.const_:
          var v = state.statementParser.variableDeclarationParser.parse();
          if (v == null) return null;
          fields.add(v);
          break;
        default:
          var v = state.statementParser.variableDeclarationParser
              .parse(mut: VariableMutability.var_);
          if (v == null) return null;
          fields.add(v);
          break;
      }
=======
      VariableDeclarationStatementContext v = parseDataClass();
      if (v == null) return null;
>>>>>>> a74882f7d754f12d199f21700d9b663870b2711d
      peek = state.nextToken(TokenType.rParen);
      if (peek == null) return null;
      fields.add(v);
      lastSpan = peek.span;
    }

    peek = state.nextToken(TokenType.lCurly);
    if (peek != null) {
      for (peek = state.peek();
          peek.type != TokenType.rCurly;
          peek = state.peek()) {
        // Parse class declaration body
        switch (peek.type) {
          case TokenType.let:
          case TokenType.var_:
          case TokenType.const_:
            VariableDeclarationStatementContext v =
                state.statementParser.varDeclarationParser.parse([]);
            if (v == null) return null;
            fields.add(v);
            break;
          case TokenType.fn:
            FunctionContext f = state.parseFunction();
            if (f == null) return null;
            methods.add(f);
            break;
          default:
<<<<<<< HEAD
            var v = state.statementParser.variableDeclarationParser
                .parse(mut: VariableMutability.var_);
=======
            VariableDeclarationStatementContext v = state
                .statementParser.varDeclarationParser
                .parse([], mut: VariableMutability.var_);
>>>>>>> a74882f7d754f12d199f21700d9b663870b2711d
            if (v == null) return null;
            fields.add(v);
            break;
        }
      }

      state.consume();
      if (peek == null) return null;
      lastSpan = peek.span;
    }

    return new TypeDeclarationContext(startSpan.expand(lastSpan), name,
        fields: fields, methods: methods, isPriv: isPriv);
  }

  VariableDeclarationStatementContext parseDataClass() {
    switch (state.peek().type) {
      case TokenType.let:
      case TokenType.var_:
      case TokenType.const_:
        return state.statementParser.varDeclarationParser.parse([]);
      default:
        return state.statementParser.varDeclarationParser
            .parse([], mut: VariableMutability.var_);
    }
  }
}

class EnumDeclarationParser {
  final Parser state;

  EnumDeclarationParser(this.state);

  /// enum { a, b, c }
  EnumDeclarationContext parse({List<Comment> comments}) {
    Token start = state.nextToken(TokenType.enum_);
    if (start == null) return null;

    SimpleIdentifierContext name = state.parseSimpleIdentifier();
    if (name == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing name in enum declaration.", start.span));
      return null;
    }

    // Optional assign
    state.nextToken(TokenType.assign);

    var lCurly = state.nextToken(TokenType.lCurly);
    if (lCurly == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing '{' in enum type definition.", start.span));
      return null;
    }

    var values = <EnumValueContext>[];

    for (EnumValueContext value =
            parseEnumValue(comments: state.parseComments());
        value != null;
        value = parseEnumValue(comments: state.parseComments())) {
      values.add(value);

      if (state.nextToken(TokenType.comma) == null) break;
    }

    var rCurly = state.nextToken(TokenType.rCurly)?.span;

    if (rCurly == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing '}' in enum type definition.", lCurly.span));
      return null;
    }

    return new EnumDeclarationContext(
        name, values, start.span.expand(rCurly), comments);
  }

  EnumValueContext parseEnumValue({List<Comment> comments}) {
    SimpleIdentifierContext name = state.parseSimpleIdentifier();

    if (name == null) return null;

    NumberLiteralContext index;

    // Index is optional
    FileSpan assign = state.nextToken(TokenType.assign)?.span;

    if (assign != null) {
      index = state.expressionParser.parseNumberLiteral();

      if (index == null) {
        state.errors.add(new BonoboError(BonoboErrorSeverity.error,
            "Missing index after '=' in enum type definition.", assign));
        return null;
      }
    }

    FileSpan span = name.span;
    if (index != null) span.expand(index.span);

    return new EnumValueContext(name, index, span, comments);
  }
}
