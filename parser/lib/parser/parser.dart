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

CompilationUnitContext parseCompilationUnit(Scanner scanner) =>
    new Parser(scanner).parseCompilationUnit();

class Parser extends BaseParser {
  Parser(Scanner scanner) : super(scanner);

  CompilationUnitContext parseCompilationUnit() {
    // TODO reset?

    FileSpan startSpan = peek().span;
    FileSpan lastSpan = startSpan;

    var functions = <FunctionContext>[], typedefs = <TypedefContext>[];
    //final classes = <TypeDeclarationContext>[];
    //final enums = <EnumDeclarationContext>[];

    while (!done) {
      var comments = parseComments();
      Token t = peek();
      switch (t.type) {
        case TokenType.fn:
          FunctionContext f = parseFunction(comments: comments);
          if (f != null) {
            functions.add(f);
            lastSpan = f.span;
          }
          break;
        case TokenType.type:
          var typedef_ = typedefParser.parse(comments: comments);
          if (typedef_ != null) {
            typedefs.add(typedef_);
            lastSpan = typedef_.span;
          }
          break;
        /*case TokenType.type:
          TypeDeclarationContext c = parseTypeDeclaration();
          if (c != null) {
            classes.add(c);
            lastSpan = c.span;
          }
          break;
        case TokenType.enum_:
          EnumDeclarationContext c = parsEnumDeclaration();
          if (c != null) {
            enums.add(c);
            lastSpan = c.span;
          }
          break;*/
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

    return new CompilationUnitContext(
        functions, typedefs, startSpan.expand(lastSpan), []);
    /*
    return new CompilationUnitContext(startSpan.expand(lastSpan), [],
        functions: functions, classes: classes, enums: enums);
        */
  }

  FunctionContext parseFunction({List<Comment> comments}) {
    // TODO comments
    return functionParser.parse();
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

  /*
  TypeDeclarationParser _typeDeclarationParser;

  TypeDeclarationParser get typeDeclarationParser =>
      _typeDeclarationParser ??= new TypeDeclarationParser(this);

  EnumDeclarationParser _enumDeclarationParser;

  EnumDeclarationParser get enumDeclarationParser =>
      _enumDeclarationParser ??= new EnumDeclarationParser(this);
    */

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
