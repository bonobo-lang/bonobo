import 'dart:collection';
import 'package:source_span/source_span.dart';
import '../ast/ast.dart';
import '../scanner/scanner.dart';

part 'expression/prefix.dart';

part 'expression/infix.dart';

part 'expression/postfix.dart';

part 'base.dart';

part 'function.dart';

part 'expression.dart';

part 'type_decl.dart';

part 'type.dart';

part 'typedef.dart';

part 'statement/statement.dart';

part 'statement/variable_declaration.dart';

CompilationUnitContext parseCompilationUnit(Scanner scanner) =>
    new Parser(scanner).parseCompilationUnit();

class Parser extends BaseParser {
  ExpressionParser expressionParser;
  FunctionParser functionParser;
  StatementParser statementParser;
  TypeParser typeParser;
  TypedefParser typedefParser;

  Parser(Scanner scanner) : super(scanner) {
    expressionParser = new ExpressionParser(this);
    functionParser = new FunctionParser(this);
    statementParser = new StatementParser(this);
    typeParser = new TypeParser(this);
    typedefParser = new TypedefParser(this);
  }

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
          var ctx = functionParser.parse(comments: comments);
          if (ctx != null) {
            functions.add(ctx);
            lastSpan = ctx.span;
          }
          break;
        case TokenType.type:
          var ctx = typedefParser.parse(comments: comments);
          if (ctx != null) {
            typedefs.add(ctx);
            lastSpan = ctx.span;
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
          errors.add(new BonoboError(BonoboErrorSeverity.warning,
              "Unexpected text '${t.span.text}'.", t.span));
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

  /// Parses function name
  SimpleIdentifierContext parseSimpleIdentifier({List<Comment> comments}) {
    if (peek()?.type == TokenType.identifier)
      return new SimpleIdentifierContext(consume().span, comments ?? []);
    return null;
  }

  IdentifierContext parseIdentifier({List<Comment> comments}) =>
      const _IdentifierParser().parse(this, comments: comments);

/*
  TypeDeclarationParser _typeDeclarationParser;

  TypeDeclarationParser get typeDeclarationParser =>
      _typeDeclarationParser ??= new TypeDeclarationParser(this);

  EnumDeclarationParser _enumDeclarationParser;

  EnumDeclarationParser get enumDeclarationParser =>
      _enumDeclarationParser ??= new EnumDeclarationParser(this);
    */
}
