part of 'parser.dart';

class ClassDeclParser {
  final BonoboParseState state;

  ClassDeclParser(this.state);

  ClassDeclContext parse() {
    FileSpan startSpan = state.peek().span;

    if (state.nextToken(TokenType.clazz) == null) return null;

    bool isPub = state.nextToken(TokenType.pub) != null;

    // TODO final modifier

    SimpleIdentifierContext name = state.nextSimpleId();

    if (name == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Expected class name.",
          state.peek().span /* TODO What if there is no token? */));
      return null;
    }

    Token peek = state.peek();

    if (peek.type == TokenType.implements) {
      // TODO parse implements clause
      throw new UnimplementedError('implements');
      peek = state.peek();
    }

    if (peek.type == TokenType.implements) {
      // TODO parse mixes clause
      throw new UnimplementedError('mixes');
      peek = state.peek();
    }

    final fields = <VarDeclStContext>[];
    final methods = <FunctionContext>[];

    // TODO parse data classes

    peek = state.nextToken(TokenType.lCurly);
    if (peek == null) return null;

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
          // TODO error
          return null;
          break;
      }
    }

    state.consume();
    if (peek == null) return null;

    return new ClassDeclContext(startSpan.expand(peek.span), name,
        fields: fields, methods: methods, isPub: isPub);
  }
}
