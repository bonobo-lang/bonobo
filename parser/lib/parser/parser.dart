import 'dart:collection';
import 'package:source_span/source_span.dart';
import 'package:scanner/scanner.dart';
import 'package:ast/ast.dart';

part 'base.dart';
part 'infix.dart';
part 'prefix.dart';
part 'function.dart';
part 'expression.dart';

part 'statement/statement.dart';

UnitContext parseUnit(Scanner scanner) => new BonoboParseState(scanner).parse();

class BonoboParseState extends ParserState {
  BonoboParseState(Scanner scanner) : super(scanner);

  UnitContext parse() {
    // TODO reset?

    FileSpan span;
    final functions = <FunctionContext>[];

    while (!done) {
      Token t = peek();
      switch (t.type) {
        case TokenType.func:
          FunctionContext f = nextFunc();
          if (f != null) {
            functions.add(f);
            span == null ? span = f.span : span = span.expand(f.span);
          }
          break;
        default:
          // TODO
          throw new UnimplementedError();
          break;
      }
      if (errors.length != null) {
        // TODO what do we do here?
        break;
      }
    }

    return new UnitContext(span ?? scanner.emptySpan, functions);
  }

  FunctionContext nextFunc() {
    // TODO comments
    return funcParser.parse();
  }

  TypeContext nextType() {
    IdentifierContext id = idParser.parse();
    return id == null ? null : new IdentifierTypeContext(id, []);
  }

  /// Parses function name
  SimpleIdentifierContext nextSimpleId() {
    Token id = nextToken(TokenType.identifier);
    return id == null ? null : new SimpleIdentifierContext(id.span, []);
  }

  IdentifierContext nextId() => idParser.parse();

  ExpressionContext nextExp(int precedence, bool inVariableDeclaration) =>
      expParser.parse(precedence, inVariableDeclaration);

  FunctionParser _funcParser;
  FunctionParser get funcParser => _funcParser ?? new FunctionParser(this);

  IdentifierParser _idParser;
  IdentifierParser get idParser => _idParser ?? new IdentifierParser(this);

  ExpressionParser _expParser;
  ExpressionParser get expParser => _expParser ?? new ExpressionParser(this);

  /*
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
  */
}

typedef ExpressionContext PrefixParselet(BonoboParseState parser, Token token,
    List<Comment> comments, bool inVariableDeclaration);

class InfixParselet {
  final int precedence;

  final ExpressionContext Function(
      BonoboParseState parser,
      ExpressionContext left,
      Token token,
      List<Comment> comments,
      bool inVariableDeclaration) parse;

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

          ExpressionContext right = parser.nextExp(0, inVariableDeclaration);

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
