part of 'parser.dart';

class TypeDeclParser {
  final BonoboParseState state;

  TypeDeclParser(this.state);

  ClassDeclContext parse() {
    FileSpan startSpan = state.peek().span;
    FileSpan lastSpan = startSpan;

    if (state.nextToken(TokenType.type) == null) return null;

    bool isPriv = state.nextToken(TokenType.hide_) != null;

    // TODO final modifier

    SimpleIdentifierContext name = state.nextSimpleId();

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

    final fields = <VarDeclStContext>[];
    final methods = <FunctionContext>[];

    peek = state.nextToken(TokenType.lParen);
    if (peek != null) {
      switch (state.peek().type) {
        case TokenType.let:
        case TokenType.var_:
        case TokenType.const_:
          VarDeclStContext v = state.statParser.varDeclParser.parse();
          if (v == null) return null;
          fields.add(v);
          break;
        default:
          VarDeclStContext v =
          state.statParser.varDeclParser.parse(mut: VarMut.var_);
          if (v == null) return null;
          fields.add(v);
          break;
      }
      peek = state.nextToken(TokenType.rParen);
      if (peek == null) return null;
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
            VarDeclStContext v = state.statParser.varDeclParser.parse();
            if (v == null) return null;
            fields.add(v);
            break;
          case TokenType.fn:
            FunctionContext f = state.nextFunc();
            if (f == null) return null;
            methods.add(f);
            break;
          default:
            VarDeclStContext v =
                state.statParser.varDeclParser.parse(mut: VarMut.var_);
            if (v == null) return null;
            fields.add(v);
            break;
        }
      }

      state.consume();
      if (peek == null) return null;
      lastSpan = peek.span;
    }

    return new ClassDeclContext(startSpan.expand(lastSpan), name,
        fields: fields, methods: methods, isPriv: isPriv);
  }
}
