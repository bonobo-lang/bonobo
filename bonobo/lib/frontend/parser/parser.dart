import 'dart:collection';
import 'package:source_span/source_span.dart';
import '../scanner/scanner.dart';
import 'package:bonobo/ast/ast.dart';
import 'package:bonobo/error/error.dart';

part 'parselet/infix.dart';
part 'parselet/prefix.dart';

final RegExp commentSlashes = new RegExp(r'///*');

class _Parser {
  final List<BonoboError> errors = [];
  final Scanner scanner;
  int _index = -1;

  _Parser(this.scanner) {
    errors.addAll(scanner.errors);
  }

  List<Token> computeRest() {
    if (done) return [];
    //print(_index);
    //print(scanner.tokens.skip(_index));
    return scanner.tokens.skip(_index).toList();
  }

  /// Computes the current Pratt parser precedence.
  int getPrecedence() {
    return _infixParselets[peek()?.type]?.precedence ?? 0;
  }

  /// Joins the [tokens] into a single [FileSpan].
  FileSpan spanFrom(Iterable<Token> tokens) {
    return tokens.map((t) => t.span).reduce((a, b) => a.expand(b));
  }

  /// Returns `true` if there is no more input.
  bool get done => _index >= scanner.tokens.length - 1;

  /// Lookahead without consuming.
  Token peek() {
    if (done) return null;
    return scanner.tokens[_index + 1];
  }

  /// Lookahead and consume.
  Token consume() {
    if (done) return null;
    return scanner.tokens[++_index];
  }

  /// Attempts to scan a sequence of tokens, in the given order.
  ///
  /// Returns a [Queue] (LIFO), or `null`.
  Queue<Token> next(Iterable<TokenType> types) {
    if (_index >= scanner.tokens.length - types.length - 1) return null;

    var tokens = new Queue<Token>();

    for (int i = 0; i < types.length; i++) {
      var token = scanner.tokens[_index + i + 1];

      if (token.type != types.elementAt(i)) return null;

      tokens.addFirst(token);
    }

    _index += types.length;
    return tokens;
  }

  /// Calls [next], only returning one [Token].
  Token nextToken(TokenType type) {
    return next([type])?.removeFirst();
    //return peek()?.type == type ? consume() : null;
  }

  /// Parses available comments.
  List<Comment> parseComments() {
    var comments = <Comment>[];
    Token token;

    while ((token = nextToken(TokenType.comment)) != null) {
      var lines = token.match[1]
          .split('\n')
          .map((s) => s.replaceAll(commentSlashes, '').trim());
      comments.add(new Comment(lines.join('\n')));
    }

    return comments;
  }

  /// Runs [callback]. If the [callback] returns `null`, then the parser's position will be preserved, and any parse errors will be removed.
  T lookAhead<T>(T callback()) {
    var replay = _index;
    var result = callback();
    var len = errors.length;

    if (result == null) {
      _index = replay;

      if (errors.length > len) errors.removeRange(len, errors.length - 1);
    }

    return result;
  }
}

class Parser extends _Parser {
  Parser(Scanner scanner) : super(scanner);

  CompilationUnitContext parseCompilationUnit() {
    FileSpan span;
    var functions = <FunctionContext>[];
    FunctionContext function = parseFunction(true);

    while (!done) {
      if (function != null) {
        functions.add(function);
        span == null ? span = function.span : span = span.expand(function.span);
      } else
        consume();

      function = parseFunction(true);
    }

    if (function != null) {
      functions.add(function);
      span == null ? span = function.span : span = span.expand(function.span);
    }

    var rest = computeRest();

    if (rest.isNotEmpty) {
      var extraneous = rest.map((t) => t.span).reduce((a, b) => a.expand(b));
      errors.add(new BonoboError(
          BonoboErrorSeverity.warning, "Extraneous text.", extraneous));
    }

    return new CompilationUnitContext(span ?? scanner.emptySpan, functions);
  }

  FunctionContext parseFunction(bool requireName,
      [Token f, List<Comment> comments]) {
    var modifiers = <TokenType>[];
    FileSpan span;

    if (f == null) {
      var modifier = parseModifier();

      while (modifier != null) {
        modifiers.add(modifier.type);
        span = span == null ? modifier.span : span.expand(modifier.span);
        modifier = parseModifier();
      }
    }

    comments ??= parseComments();
    f ??= nextToken(TokenType.func);
    if (f == null) return null;

    span = span == null ? f.span : span.expand(f.span);
    var name = parseSimpleIdentifier();

    if (name == null && requireName) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing name for function.", f.span));
      return null;
    }

    span = span == null ? span : span.expand(name.span);
    var signature = parseFunctionSignature(name.span);

    span = span.expand(signature.span);
    var body = parseFunctionBody();

    if (body == null) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error, "Missing function body.", signature.span));
      return null;
    }

    return new FunctionContext(
        modifiers, name, signature, body, span.expand(body.span), comments);
  }

  FunctionSignatureContext parseFunctionSignature(FileSpan currentSpan) {
    var parameterList = parseParameterList();
    var span = parameterList?.span, colon;
    TypeContext returnType;

    if ((colon = nextToken(TokenType.colon)) != null) {
      span = span == null ? colon.span : span.expand(colon.span);

      if ((returnType = parseType()) == null) {
        errors.add(new BonoboError(
            BonoboErrorSeverity.error, "Missing type after ':'.", colon.span));
      } else
        span = span.expand(returnType.span);
    }

    return new FunctionSignatureContext(
        parameterList, returnType, span ?? currentSpan, []);
  }

  ParameterListContext parseParameterList() {
    var closedParen = nextToken(TokenType.parentheses)?.span;

    if (closedParen != null) {
      return new ParameterListContext([], closedParen, []);
    }

    var lParen = nextToken(TokenType.lParen);
    if (lParen == null) return null;
    var span = lParen.span, lastSpan = span;
    var parameters = <ParameterContext>[];
    ParameterContext parameter = parseParameter();

    while (parameter != null) {
      parameters.add(parameter);
      span = span.expand(lastSpan = parameter.span);

      if (nextToken(TokenType.comma) != null) {
        parameter = parseParameter();
      } else {
        break;
      }
    }

    var rParen = nextToken(TokenType.rParen);

    if (rParen == null) {
      errors.add(
          new BonoboError(BonoboErrorSeverity.error, "Missing ')'.", lastSpan));
      return null;
    }

    span = span.expand(rParen.span);

    return new ParameterListContext(parameters, span, []);
  }

  ParameterContext parseParameter() {
    var id = parseIdentifier();
    if (id == null) return null;
    var span = id.span, colon = nextToken(TokenType.colon);
    TypeContext type;

    if (colon != null) {
      span = span.expand(colon.span);

      if ((type = parseType()) == null) {
        errors.add(new BonoboError(
            BonoboErrorSeverity.error, "Missing type after ':'.", colon.span));
      } else
        span = span.expand(type.span);
    }

    return new ParameterContext(id, type, span, []);
  }

  FunctionBodyContext parseFunctionBody() {
    return parseLambdaFunctionBody() ?? parseBlockFunctionBody();
  }

  BlockFunctionBodyContext parseBlockFunctionBody() {
    var block = parseBlock();
    return block == null ? null : new BlockFunctionBodyContext(block);
  }

  BlockContext parseBlock() {
    var span = nextToken(TokenType.lCurly)?.span, lastSpan = span;
    if (span == null) return null;
    var statements = <StatementContext>[];
    var statement = parseStatement();

    while (!done) {
      if (statement != null) {
        statements.add(statement);
        span = span.expand(lastSpan = statement.span);
      }

      if ((statement = parseStatement()) == null) {
        if (peek()?.type == TokenType.rCurly)
          break;
        else
          statement = parseStatement();
      }
    }

    var rCurly = consume();

    if (rCurly?.type != TokenType.rCurly) {
      errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing '}' in function body.", lastSpan));
      return null;
    }

    return new BlockContext(statements, span.expand(rCurly.span), []);
  }

  LambdaFunctionBodyContext parseLambdaFunctionBody() {
    var arrow = nextToken(TokenType.arrow);

    if (arrow != null) {
      var expression = parseExpression(0, false);

      if (expression == null) {
        errors.add(new BonoboError(BonoboErrorSeverity.error,
            "Missing expression after '=>'.", arrow.span));
        return null;
      } else {
        return new LambdaFunctionBodyContext(
            expression, arrow.span.expand(expression.span), []);
      }
    } else
      return null;
  }

  TypeContext parseType() {
    return parseIdentifierType();
  }

  IdentifierTypeContext parseIdentifierType() {
    var id = parseIdentifier();
    return id == null ? null : new IdentifierTypeContext(id, []);
  }

  IdentifierContext parseSimpleIdentifier() {
    var id = nextToken(TokenType.identifier);
    return id == null ? null : new SimpleIdentifierContext(id.span, []);
  }

  IdentifierContext parseIdentifier() {
    var id = nextToken(TokenType.identifier);

    if (id == null) return null;

    var identifiers = <Token>[id];
    var span = id.span;

    while (peek()?.type == TokenType.double_colon) {
      var doubleColon = nextToken(TokenType.double_colon);
      span = span.expand(doubleColon.span);

      if (peek()?.type == TokenType.identifier) {
        id = consume();
      } else {
        id = null;
      }

      if (id == null) {
        if (span == null) return null;
        errors.add(new BonoboError(
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

  ExpressionContext parseExpression(
      int precedence, bool inVariableDeclaration) {
    //var comments = parseComments();
    Token token = peek();

    if (token == null) return null;

    ExpressionContext left;
    PrefixParselet prefix = _prefixParselets[token.type];

    if (prefix == null) {
      /*
      errors.add(new BonoboError(BonoboErrorSeverity.error,
          'Expected expression, found "${token.span.text}".', token.span));
          */

      left = lookAhead(parseIdentifier);
      if (left == null) return null;
    } else {
      consume();
      left = prefix(this, token, [], false);
    }

    while (precedence < getPrecedence() && left != null) {
      if (inVariableDeclaration && peek()?.type == TokenType.comma) return left;
      token = consume();

      InfixParselet infix = _infixParselets[token.type];
      left = infix.parse(this, left, token, [], inVariableDeclaration);
    }

    // TODO: Support this logic for MemberExpression
    if (left is SimpleIdentifierContext) {
      // See https://github.com/bonobo-lang/bonobo/issues/9.
      var arg = parseExpression(0, false);

      if (arg != null) {
        var span = left.span.expand(arg.span);

        if (arg.innermost is! TupleExpressionContext) {
          left = new CallExpressionContext(
            left,
            new TupleExpressionContext(
              [arg],
              arg.span,
              [],
            ),
            span,
            [],
          );
        } else {
          left = new CallExpressionContext(
            left,
            arg.innermost,
            span,
            [],
          );
        }
      }
    }

    return left;
  }

  StatementContext parseStatement() {
    return parseVariableDeclarationStatement() ??
        parseReturnStatement() ??
        parseExpressionStatement();
  }

  ReturnStatementContext parseReturnStatement() {
    var comments = <Comment>[];
    var span = lookAhead(() {
      comments.addAll(parseComments());
      return nextToken(TokenType.ret)?.span;
    });

    if (span == null) return null;
    var expression = parseExpression(0, false);

    if (expression == null) {
      errors.add(new BonoboError(BonoboErrorSeverity.error,
          "Missing expression in return statement.", span));
      return null;
    }

    return new ReturnStatementContext(
        expression, span.expand(expression.span), comments);
  }

  ExpressionStatementContext parseExpressionStatement() {
    var expression = parseExpression(0, false);
    return expression == null
        ? null
        : new ExpressionStatementContext(expression.innermost);
  }

  VariableDeclarationStatementContext parseVariableDeclarationStatement() {
    /*
    var comments = <Comment>[];
    var span = lookAhead(() {
      comments.addAll(parseComments());
      return nextToken(TokenType.v)?.span;
    });*/
    var comments = parseComments(), span = nextToken(TokenType.v)?.span;

    //var lastSpan = span;
    if (span == null) return null;

    var declarations = <VariableDeclarationContext>[];
    var declaration = parseVariableDeclaration();

    while (declaration != null) {
      declarations.add(declaration);
      span = span.expand(declaration.span);

      if (nextToken(TokenType.comma) == null)
        break;
      else
        declaration = parseVariableDeclaration();
    }

    if (declarations.isEmpty) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error, 'Expected an identifier.', span));
      return null;
    }

    var declSpan = span;

    // Parse any statements after this one.
    // They all share a scope.
    var statements = <StatementContext>[];
    StatementContext statement = parseStatement();

    while (!done) {
      if (statement != null) {
        statements.add(statement);
        span = span.expand(statement.span);
      }

      if (peek()?.type == TokenType.rCurly) break;
      statement = parseStatement();
    }

    return new VariableDeclarationStatementContext(
        declarations, statements, declSpan, span, comments);
  }

  VariableDeclarationContext parseVariableDeclaration() {
    var id = parseIdentifier();
    if (id == null) return null;
    var span = id.span;
    var op = nextToken(TokenType.equals) ?? nextToken(TokenType.colon_equals);

    if (op == null) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Missing '=' or ':=' after identifier in variable declaration.",
          id.span));
      return null;
    }

    span = span.expand(op.span);
    bool isFinal = op.type == TokenType.colon_equals;
    var expression = parseExpression(0, true);

    if (expression == null) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Missing expression after '${op.span.text}' in variable declaration.",
          op.span));
      return null;
    }

    return new VariableDeclarationContext(id, expression, isFinal, span, []);
  }

  Token parseModifier() {
    for (var type in modifierTypes) {
      var token = nextToken(type);
      if (token != null) return token;
    }

    return null;
  }
}

typedef ExpressionContext PrefixParselet(Parser parser, Token token,
    List<Comment> comments, bool inVariableDeclaration);

class InfixParselet {
  final int precedence;

  final ExpressionContext Function(Parser parser, ExpressionContext left,
      Token token, List<Comment> comments, bool inVariableDeclaration) parse;

  const InfixParselet(this.precedence, this.parse);
}

class BinaryParselet extends InfixParselet {
  BinaryParselet(int precedence)
      : super(precedence,
            (parser, left, token, comments, inVariableDeclaration) {
          var span = left.span.expand(token.span), lastSpan = span;
          var equals = token.type == TokenType.equals
              ? null
              : parser.nextToken(TokenType.equals)?.span;

          if (equals != null) {
            span = span.expand(lastSpan = equals);
          }

          var right = parser.parseExpression(0, inVariableDeclaration);

          if (right == null) {
            parser.errors.add(new BonoboError(BonoboErrorSeverity.error,
                "Missing expression after '${lastSpan.text}'.", lastSpan));
            return null;
          }

          span = span.expand(right.span);

          if (equals != null || token.type == TokenType.equals) {
            return new AssignmentExpressionContext(
              left,
              token,
              right,
              span,
              []..addAll(comments)..addAll(right.comments),
            );
          }

          return new BinaryExpressionContext(
            left,
            token,
            right,
            span,
            []..addAll(comments)..addAll(right.comments),
          );
        });
}
