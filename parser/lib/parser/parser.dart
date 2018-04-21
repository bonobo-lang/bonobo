import 'dart:collection';
import 'package:source_span/source_span.dart';
import 'package:scanner/scanner.dart';
import 'package:ast/ast.dart';

part 'base.dart';
part 'function.dart';
part 'expression.dart';
part 'identifier.dart';
part 'type_decl.dart';
part 'type.dart';
part 'statement/statement.dart';
part 'statement/var_decl.dart';

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
        case TokenType.type:
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

  ClassDeclContext nextClass() {
    // TODO comments
    return classParser.parse();
  }

  TypeContext nextType() => typeParser.parse();

  StatementContext nextStatement() => statParser.parse();

  /// Parses function name
  SimpleIdentifierContext nextSimpleId() {
    if (peek()?.type == TokenType.identifier)
      return new SimpleIdentifierContext(consume().span, []);
    return null;
  }

  IdentifierContext nextId() => idParser.parse();

  ExpressionContext nextExp() => expParser.parse();

  TypeDeclParser _classParser;
  TypeDeclParser get classParser => _classParser ?? new TypeDeclParser(this);

  FunctionParser _funcParser;
  FunctionParser get funcParser => _funcParser ?? new FunctionParser(this);

  IdentifierParser _idParser;
  IdentifierParser get idParser => _idParser ?? new IdentifierParser(this);

  ExpressionParser _expParser;
  ExpressionParser get expParser => _expParser ?? new ExpressionParser(this);

  StatementParser _statParser;
  StatementParser get statParser => _statParser ?? new StatementParser(this);

  TypeParser _typeParser;
  TypeParser get typeParser => _typeParser ?? new TypeParser(this);

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
