part of 'parser.dart';

class TypeParser {
  final Parser state;

  TypeParser(this.state);

  TypeContext parse() {
    // TODO parse special List syntax
    // TODO parse special Map syntax

    Token decider = state.peek();
    if (decider == null) return null;

    if (decider.type == TokenType.lParen) {
      // TODO anonymous type
      throw new UnimplementedError('Tuple types');
    }

    if (decider.type == TokenType.fn) {
      return parseFunction();
    }

    // TODO

    IdentifierContext name = state.parseIdentifier();
    FileSpan lastSpan = name.span;
    if (name == null) return null;

    // TODO parse generics

    return new NamedTypeContext(name.span.expand(lastSpan), [], name);
  }

  AnonymousTypeContext parseAnonymousType() {
    Token lCurly = state.nextToken(TokenType.lCurly);
    if (lCurly == null) return null;

    VariableDeclarationStatementContext fields =
        state.typeDeclarationParser.parseDataClass();
    if (fields == null) return null;

    Token rCurly = state.nextToken(TokenType.rCurly);
    if (rCurly == null) return null;

    return new AnonymousTypeContext(
        lCurly.span.expand(rCurly.span), [], fields);
  }

  FunctionTypeContext parseFunction() {
    Token fn = state.nextToken(TokenType.fn);
    if (fn == null) return null;

    FunctionSignatureContext signature =
        state.functionParser.parseSignature(fn.span);
    if (signature == null) return null;

    if (signature.returnType == null && signature.returnType == null) {
      // TODO error
      return null;
    }

    FileSpan span = fn.span.expand(signature.returnType != null
        ? signature.returnType.span
        : signature.parameterList.span);

    return new FunctionTypeContext(span, [], signature);
  }
}
