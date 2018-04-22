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

    final fields = <VarDeclarationStatementContext>[];
    final methods = <FunctionContext>[];

    peek = state.nextToken(TokenType.lParen);
    if (peek != null) {
      VarDeclarationStatementContext v = parseDataClass();
      if (v == null) return null;
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
            VarDeclarationStatementContext v =
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
            VarDeclarationStatementContext v = state
                .statementParser.varDeclarationParser
                .parse([], mut: VariableMutability.var_);
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

  VarDeclarationStatementContext parseDataClass() {
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
