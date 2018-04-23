part of 'parser.dart';

class TypeParser {
  final Parser state;

  TypeParser(this.state);

  // When calling `parse` from methods within this class,
  // Be sure to forward the value of `ignoreComma`. Otherwise,
  // there can be ambiguity when a comma appears in a variable declaration statement.
  TypeContext parse({List<Comment> comments, bool ignoreComma: false}) {
    // TODO parse special List syntax
    // TODO parse special Map syntax

    TypeContext type =
        parseSingleType(comments: comments, ignoreComma: ignoreComma);

    if (type == null) return null;

    while (!state.done) {
      switch (state.peek()?.type) {
        case TokenType.comma:
          if (ignoreComma == true) return type;
          // Consume the token, then read in the other type in this tuple.
          var comma = state.consume();
          var nextType = parse(comments: state.parseComments());
          var span = type.span.expand(nextType.span);

          if (nextType == null) {
            state.errors.add(new BonoboError(BonoboErrorSeverity.error,
                "Missing type after ','.", comma.span));
            return null;
          }

          // If the other type is a tuple, combine the two.
          if (nextType is TupleTypeContext) {
            var tup = nextType.innermost as TupleTypeContext;
            type = new TupleTypeContext([type]..addAll(tup.items), span,
                []..addAll(comments)..addAll(tup.comments));
          }

          // Otherwise, create a new one.
          else {
            type = new TupleTypeContext(
                [type.innermost, nextType.innermost], span, comments);
          }
          break;
        default:
          return type;
      }
    }

    return type;
    // TODO parse generics
  }

  TypeContext parseSingleType(
      {List<Comment> comments, bool ignoreComma: false}) {
    IdentifierContext name = state.parseIdentifier();

    if (name == null) {
      // If we didn't find an identifier type,
      // try for a struct or parenthesized type, etc.
      return parseFunctionType(comments: comments, ignoreComma: ignoreComma) ??
          parseEnumType(comments: comments) ??
          parseStructType(comments: comments) ??
          parseParenthesizedType(comments: comments);
    }

    if (name is NamespacedIdentifierContext) {
      return new NamespacedIdentifierTypeContext(name, comments ?? []);
    } else {
      return new SimpleIdentifierTypeContext(name, comments ?? []);
    }
  }

  /// enum { a, b, c }
  EnumTypeContext parseEnumType({List<Comment> comments}) {
    var keyword = state.nextToken(TokenType.enum_),
        span = keyword?.span,
        lastSpan = span;

    if (keyword == null) return null;

    var lCurly = state.nextToken(TokenType.lCurly);

    if (lCurly == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing '{' in enum type definition.", lastSpan));
      return null;
    }

    span = span.expand(lastSpan = lCurly.span);
    var values = <EnumValueContext>[];
    var value = parseEnumValue(comments: state.parseComments());

    while (value != null) {
      values.add(value);
      span = span.expand(lastSpan = value.span);

      if (state.peek()?.type == TokenType.comma) {
        span = span.expand(lastSpan = state.consume().span);
        value = parseEnumValue(comments: state.parseComments());
      } else {
        break;
      }
    }

    var rCurly = state.nextToken(TokenType.rCurly)?.span;

    if (rCurly == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing '}' in enum type definition.", lastSpan));
      return null;
    }

    return new EnumTypeContext(values, span.expand(rCurly), comments);
  }

  EnumValueContext parseEnumValue({List<Comment> comments}) {
    var name = state.parseSimpleIdentifier(), span = name?.span;
    NumberLiteralContext index;

    if (name == null) return null;

    // Index is optional
    var assign = state.nextToken(TokenType.assign)?.span;

    if (assign != null) {
      span = span.expand(assign);
      index = state.expressionParser.parseNumberLiteral();

      if (index == null) {
        state.errors.add(new BonoboError(BonoboErrorSeverity.error,
            "Missing index after '=' in enum type definition.", assign));
        return null;
      }

      span = span.expand(index.span);
    }

    return new EnumValueContext(name, index, span, comments);
  }

  /// fn(Int, Int): Int
  FunctionTypeContext parseFunctionType(
      {List<Comment> comments, bool ignoreComma: false}) {
    var fn = state.nextToken(TokenType.fn), span = fn?.span, lastSpan = span;

    if (fn == null) return null;

    // The parameter list is optional.
    var parameters = <TypeContext>[];

    if (state.peek()?.type == TokenType.lParen) {
      span = span.expand(lastSpan = state.consume().span);
      var parameter = parse(comments: state.parseComments(), ignoreComma: true);

      while (parameter != null) {
        parameters.add(parameter);
        span = span.expand(lastSpan = parameter.span);

        if (state.peek()?.type == TokenType.comma) {
          span = span.expand(lastSpan = state.consume().span);
          parameter = parse(comments: state.parseComments(), ignoreComma: true);
        } else {
          break;
        }
      }

      var rParen = state.nextToken(TokenType.rParen)?.span;

      if (rParen == null) {
        state.errors.add(new BonoboError(BonoboErrorSeverity.error,
            "Missing ')' in function type literal.", lastSpan));
        return null;
      }

      span = span.expand(lastSpan = rParen);
    }

    // The return type is never optional.
    var colon = state.nextToken(TokenType.colon);

    if (colon == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing ':' in function type literal.", lastSpan));
    }

    span = span.expand(lastSpan = colon.span);
    var returnType =
        parse(comments: state.parseComments(), ignoreComma: ignoreComma);

    if (returnType == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing return type after ':'.", lastSpan));
      return null;
    }

    span = span.expand(lastSpan = returnType.span);
    return new FunctionTypeContext(parameters, returnType, span, comments);
  }

  StructTypeContext parseStructType({List<Comment> comments}) {
    var lCurly = state.nextToken(TokenType.lCurly),
        span = lCurly?.span,
        lastSpan = span;

    if (lCurly == null) return null;

    var fields = <StructFieldContext>[],
        field = parseStructField(comments: state.parseComments());

    while (field != null) {
      fields.add(field);
      span = span.expand(lastSpan = field.span);

      // Optional comma
      if (state.peek()?.type == TokenType.comma) {
        span = span.expand(lastSpan = state.consume().span);
        field = parseStructField(comments: state.parseComments());

        if (field == null) {
          state.errors.add(new BonoboError(
              BonoboErrorSeverity.error, "Missing field after ','.", lastSpan));
          return null;
        }
      } else
        field = parseStructField(comments: state.parseComments());
    }

    var rCurly = state.nextToken(TokenType.rCurly);

    if (rCurly == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing '}' in struct type definition.", lastSpan));
      return null;
    }

    return new StructTypeContext(fields, span, comments);
  }

  StructFieldContext parseStructField({List<Comment> comments}) {
    if (state.peek()?.type == TokenType.fn)
      return parseStructFunctionField(comments: comments);

    var name = state.parseSimpleIdentifier(),
        span = name?.span,
        lastSpan = span;

    if (name == null) return null;

    var colon = state.nextToken(TokenType.colon);

    if (colon == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing ':' after '${name.name}'.", lastSpan));
      return null;
    }

    span = span.expand(lastSpan = colon.span);

    var type = parse(comments: state.parseComments(), ignoreComma: true);

    if (type == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing type after ':'.", colon.span));
      return null;
    }

    span = span.expand(type.span);
    return new StructFieldContext(name, type, span, comments);
  }

  /// Syntactic sugar.
  ///
  /// Ex.
  ///
  /// `{ fn myFn(Int, String): Double }`
  /// automatically maps to
  /// `{ myFn: fn(Int, String): Double }`.
  StructFieldContext parseStructFunctionField({List<Comment> comments}) {
    var fn = state.nextToken(TokenType.fn);

    if (fn == null) return null;

    var span = fn.span;
    var name = state.parseSimpleIdentifier();

    if (name == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing identifier after 'fn'.", fn.span));
      return null;
    }

    span = span.expand(name.span);
    var signature = state.functionParser.parseSignature();

    if (signature == null) {
      state.errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing function signature after '${name.name}'.", name.span));
      return null;
    }

    span = span.expand(signature.span);

    // Manufacture a FunctionTypeContext
    var functionType = new FunctionTypeContext(
        signature.parameterList?.parameters
                ?.map((p) =>
                    p.type ??
                    new SimpleIdentifierTypeContext(p.name, p.comments))
                ?.toList() ??
            [],
        signature.returnType,
        signature.span,
        comments);

    // Then, create a StructField with the item's name.
    return new StructFieldContext(name, functionType, span, comments);
  }

  ParenthesizedTypeContext parseParenthesizedType({List<Comment> comments}) {
    var span = state.nextToken(TokenType.lParen)?.span, lastSpan = span;

    if (span == null) return null;

    var inner = parse(comments: state.parseComments(), ignoreComma: false);

    if (inner == null) {
      state.errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing type after '('.", lastSpan));
      return null;
    }

    span = span.expand(lastSpan = inner.span);
    var rParen = state.nextToken(TokenType.rParen)?.span;

    if (rParen == null) {
      state.errors.add(
          new BonoboError(BonoboErrorSeverity.error, "Missing ')'.", lastSpan));
      return null;
    }

    return new ParenthesizedTypeContext(inner, span, comments ?? []);
  }
}
