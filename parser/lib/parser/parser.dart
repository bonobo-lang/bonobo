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

CompilationUnitContext parseCompilationUnit(Scanner scanner) =>
    new Parser(scanner).parseCompilationUnit();

class Parser extends BaseParser {
  Parser(Scanner scanner) : super(scanner);

  CompilationUnitContext parseCompilationUnit() {
    // TODO reset?

    FileSpan startSpan = peek().span;
    FileSpan lastSpan = startSpan;

    final functions = <FunctionContext>[];
    final classes = <TypeDeclarationContext>[];

    while (!done) {
      Token t = peek();
      switch (t.type) {
        case TokenType.fn:
          FunctionContext f = parseFunction();
          if (f != null) {
            functions.add(f);
            lastSpan = f.span;
          }
          break;
        case TokenType.type:
          TypeDeclarationContext c = parseTypeDeclaration();
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

    return new CompilationUnitContext(startSpan.expand(lastSpan), [],
        functions: functions, classes: classes);
  }

  FunctionContext parseFunction({List<Comment> comments}) {
    // TODO comments
    return functionParser.parse();
  }

  TypeDeclarationContext parseTypeDeclaration() {
    // TODO comments
    return typeDeclarationParser.parse();
  }

  TypeContext parseType() => typeParser.parse();

  StatementContext parseStatement() => statementParser.parse();

  /// Parses function name
  SimpleIdentifierContext parseSimpleIdentifier() {
    if (peek()?.type == TokenType.identifier)
      return new SimpleIdentifierContext(consume().span, []);
    return null;
  }

  IdentifierContext parseIdentifier() => identifierParser.parse();

  ExpressionContext parseExpression() => expressionParser.parse();

  TypeDeclarationParser _typeDeclarationParser;

  TypeDeclarationParser get typeDeclarationParser =>
      _typeDeclarationParser ??= new TypeDeclarationParser(this);

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
}
