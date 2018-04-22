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

part 'typedef.dart';

part 'statement/statement.dart';

part 'statement/var_decl.dart';

CompilationUnitContext parseUnit(Scanner scanner) =>
    new Parser(scanner).parseCompilationUnit();

class Parser extends BaseParser {
  Parser(Scanner scanner) : super(scanner);

  CompilationUnitContext parseCompilationUnit() {
    // TODO reset?

    var span = peek()?.span, lastSpan = span;

    if (span == null) return null;

    final functions = <FunctionContext>[];
    final classes = <ClassDeclarationContext>[];
    final typedefs = <TypedefContext>[];

    while (!done) {
      var comments = parseComments();
      Token t = peek();

      switch (t.type) {
        case TokenType.fn:
          FunctionContext f = parseFunction();
          if (f != null) {
            functions.add(f);
            span = span.expand(lastSpan = f.span);
          }
          break;
        case TokenType.type:
          var typedef = parseTypedef(comments: comments);
          if (typedef != null) {
            typedefs.add(typedef);
            span = span.expand(lastSpan = typedef.span);
          }
          /*
          ClassDeclarationContext c = parseClass();
          if (c != null) {
            classes.add(c);
            lastSpan = c.span;
          }*/
          break;
        default:
          errors.add(new BonoboError(BonoboErrorSeverity.warning,
              "Unexpected token: ${t.type}", t.span));
          consume();
          break;
      }
      if (errors.length != 0) {
        // TODO what do we do here?
        break;
      }
    }

    return new CompilationUnitContext(
      span,
      [],
      functions: functions,
      classes: classes,
      typedefs: typedefs,
    );
  }

  FunctionContext parseFunction({List<Comment> comments}) {
    // TODO comments
    return functionParser.parse();
  }

  TypedefContext parseTypedef({List<Comment> comments}) {
    return typedefParser.parse(comments: comments);
  }

  StatementContext parseStatement() => statementParser.parse();

  /// Parses function name
  SimpleIdentifierContext parseSimpleIdentifier() {
    if (peek()?.type == TokenType.identifier)
      return new SimpleIdentifierContext(consume().span, []);
    return null;
  }

  IdentifierContext parseIdentifier() => identifierParser.parse();

  ExpressionContext parseExpression() => expressionParser.parse();

  TypeDeclParser _classParser;

  TypeDeclParser get classParser => _classParser ??= new TypeDeclParser(this);

  FunctionParser _funcParser;

  FunctionParser get functionParser => _funcParser ??= new FunctionParser(this);

  IdentifierParser _idParser;

  IdentifierParser get identifierParser =>
      _idParser ??= new IdentifierParser(this);

  ExpressionParser _expParser;

  ExpressionParser get expressionParser =>
      _expParser ??= new ExpressionParser(this);

  StatementParser _statParser;

  StatementParser get statementParser =>
      _statParser ??= new StatementParser(this);

  TypeParser _typeParser;

  TypeParser get typeParser => _typeParser ??= new TypeParser(this);

  TypedefParser _typedefParser;

  TypedefParser get typedefParser => _typedefParser ??= new TypedefParser(this);
}
