import 'dart:collection';
import 'package:source_span/source_span.dart';
import 'package:scanner/scanner.dart';
import 'package:ast/ast.dart';

part 'base.dart';
part 'infix.dart';
part 'function.dart';
part 'expression.dart';
part 'identifier.dart';
part 'class.dart';
part 'type.dart';
part 'statement/statement.dart';
part 'parselet.dart';

UnitContext parseUnit(Scanner scanner) => new BonoboParseState(scanner).parse();

class BonoboParseState extends ParserState {
  BonoboParseState(Scanner scanner) : super(scanner);

  UnitContext parse() {
    // TODO reset?

    FileSpan startSpan = peek().span;
    FileSpan lastSpan = startSpan;

    final functions = <FunctionContext>[];
    final classes = <ClassDeclContext>[];

    while (!done) {
      Token t = peek();
      switch (t.type) {
        case TokenType.fn:
          FunctionContext f = nextFunc();
          if (f != null) {
            functions.add(f);
            lastSpan = f.span;
          }
          break;
        case TokenType.clazz:
          ClassDeclContext c = nextClass();
          if (c != null) {
            classes.add(c);
            lastSpan = c.span;
          }
          break;
        default:
          // TODO
          throw new UnimplementedError();
          break;
      }
      if (errors.length != 0) {
        // TODO what do we do here?
        break;
      }
    }

    return new UnitContext(startSpan.expand(lastSpan),
        functions: functions, classes: classes);
  }

  FunctionContext nextFunc() {
    // TODO comments
    return funcParser.parse();
  }

  nextClass() {
    // TODO comments
    return classParser.parse();
  }

  TypeContext nextType(int precedence) {
    Token token = peek();

    if (token == null) return null;

    TypeContext left;
    PrefixParselet<TypeContext> prefix = _typePrefixParselets[token.type];
    consume();
    left = prefix(this, token, [], false);

    while (precedence < getTypePrecedence() && left != null) {
      token = consume();
      InfixParselet infix = _typeInfixParselets[token.type];
      left = infix.parse(this, left, token, []);
    }

    return left;
  }

  StatementContext nextStatement() => statParser.parse();

  /// Parses function name
  SimpleIdentifierContext nextSimpleId() {
    if (peek()?.type == TokenType.identifier)
      return new SimpleIdentifierContext(consume().span, []);
    return null;
  }

  IdentifierContext nextId() => idParser.parse();

  ExpressionContext nextExp(int precedence) => expParser.parse(precedence);

  ClassDeclParser _classParser;
  ClassDeclParser get classParser => _classParser ?? new ClassDeclParser(this);

  FunctionParser _funcParser;
  FunctionParser get funcParser => _funcParser ?? new FunctionParser(this);

  IdentifierParser _idParser;
  IdentifierParser get idParser => _idParser ?? new IdentifierParser(this);

  ExpressionParser _expParser;
  ExpressionParser get expParser => _expParser ?? new ExpressionParser(this);

  StatementParser _statParser;
  StatementParser get statParser => _statParser ?? new StatementParser(this);

  /// Parses available comments.
  List<Comment> nextComments() {
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
}
