import 'dart:async';
import 'package:c_builder/c_builder.dart' as c;
import 'package:source_span/source_span.dart';
import 'package:symbol_table/symbol_table.dart';
import 'package:bonobo/bonobo.dart';
import 'package:bonobo/analysis/analysis.dart';
import '../scanner/scanner.dart';
import '../ast/ast.dart';

final c.Expression String_new = new c.Expression('String_new');

class BonoboCCompiler {
  final List<BonoboError> errors = [];
  final c.CompilationUnit output = new c.CompilationUnit();
  final BonoboAnalyzer analyzer;

  BonoboCCompiler(this.analyzer) {
    errors.addAll(analyzer.errors);
  }

  Future compile() async {
    var signatures = <c.FunctionSignature>[];

    if (analyzer.module.mainFunction == null) {
      errors.add(new BonoboError(
        BonoboErrorSeverity.error,
        "A 'main' function is required.",
        analyzer.module.emptySpan,
      ));
    } else {
      // Compile all functions, in all modules.
      Future compileModule(BonoboModule module) async {
        for (var symbol in module.scope.allVariables) {
          if (symbol.value is BonoboFunction)
            await compileFunction(symbol.value, signatures);
        }

        for (var child in module.children) await compileModule(child);
      }

      await compileModule(analyzer.module);

      // Insert forward declarations of all functions
      output.body.insertAll(0, signatures);

      // Insert all includes
      output.body.insertAll(0, [
        // Necessary standard imports.
        //new c.Include.system('stdint.h'),
        //new c.Include.system('stdio.h'),

        // Import the Bonobo runtime.
        new c.Include.system('bonobo.h'),
      ]);

      // Create a simple int main() that just calls _main()
      output.body
          .add(new c.CFunction(new c.FunctionSignature(c.CType.int, '_start'))
            ..body.addAll([
              new c.Expression(analyzer.module.mainFunction.fullName
                  .replaceAll('::', '_')).invoke([]),
              new c.Expression.value(0).asReturn(),
            ]));
    }
  }

  Future compileFunction(
      BonoboFunction function, List<c.FunctionSignature> signatures) async {
    if (function is BonoboNativeFunction) {
      await function.compileC(this, signatures);
      return;
    }

    var returnType = await compileType(function.returnType);

    if (returnType == null) {
      errors.add(new BonoboError(
          BonoboErrorSeverity.error,
          "Cannot resolve type '${function.returnType.name}' to a C type.",
          function.declaration.signature.returnType?.span ??
              function.declaration.signature.span));
      return;
    }

    var signature = new c.FunctionSignature(
        returnType, function.fullName.replaceAll('::', '_'));
    signatures.add(signature);
    var out = new c.CFunction(signature);
    output.body.add(out);

    for (var p in function.parameters) {
      var type = await compileType(p.type);

      if (type == null) {
        errors.add(new BonoboError(
            BonoboErrorSeverity.error,
            "Cannot resolve type of parameter '${p.name}' to a C type.",
            p.span));
        return;
      }

      out.signature.parameters.add(new c.Parameter(type, p.name));
    }

    out.body.addAll(
        await compileControlFlow(function.body, function, function.scope));
  }

  Future<List<c.Code>> compileControlFlow(
      ControlFlow ctx, BonoboFunction function, SymbolTable scope) async {
    var out = [];

    if (ctx?.statements == null) return out;

    for (int i = 0; i < ctx.statements.length; i++) {
      var stmt = ctx.statements[i];

      if (stmt is ReturnStatementContext) {
        var expression =
            await compileExpression(stmt.expression, function, out, scope);
        out.add(expression.asReturn());
        continue;
      }

      if (stmt is VariableDeclarationStatementContext) {
        // Declare all variables
        for (var decl in stmt.declarations) {
          var value = await analyzer.expressionAnalyzer
              .resolve(decl.expression, function, scope);
          var cExpression =
              await compileExpression(decl.expression, function, out, scope);
          var type = await compileType(value.type);
          out.add(new c.Field(type, decl.name.name, cExpression));
        }

        // Then, walk the remaining statements
        out.addAll(await compileControlFlow(stmt.flow, function, scope));
      }
    }

    return out;
  }

  Future<c.CType> compileType(BonoboType type) async {
    // TODO: Array types? Generics?
    return type.ctype;
  }

  Future<c.Expression> compileExpression(ExpressionContext ctx,
      BonoboFunction function, List<c.Code> body, SymbolTable scope) async {
    //print('${ctx.runtimeType}\n${ctx.span.highlight()}');
    // Literals
    if (ctx is SimpleIdentifierContext) {
      return new c.Expression(ctx.name);
    }

    if (ctx is NamespacedIdentifierContext) {
      var module = analyzer.module;

      for (var namespace in ctx.namespaces) {
        var child = module.children
            .firstWhere((m) => m.name == namespace.name, orElse: () => null);

        if (child == null) {
          throw "The module '${module.name}' has no child named '${namespace
              .name}'.";
        }

        module = child;
      }

      var symbol = module.scope.allVariables
          .firstWhere((v) => v.name == ctx.symbol.name, orElse: () => null);

      if (symbol == null) {
        throw "The module '${module.name}' has no symbol named '${ctx.symbol
            .name}'.";
      }

      return new c.Expression(ctx.name.replaceAll('::', '_'));
    }

    if (ctx is NumberLiteralContext) {
      // TODO: Different types of numbers?
      return new c.Expression(ctx.span.text);
    }

    if (ctx is StringLiteralContext) {
      var value = removeQuotesFromString(ctx.span.text)
          .replaceAll("\\'", "'")
          .replaceAll('"', '\\"');
      return new c.Expression('"$value"');
      //var data = new c.Expression.value(ctx.value);
      //return String_new.invoke([data]);
    }

    if (ctx is CallExpressionContext) {
      var target = await compileExpression(ctx.target, function, body, scope);
      var arguments = await Future.wait(ctx.arguments.expressions
          .map((e) => compileExpression(e, function, body, scope)));
      return target.invoke(arguments);
    }

    if (ctx is MemberExpressionContext) {
      // TODO: better handle this
      var value =
          await analyzer.expressionAnalyzer.resolve(ctx, function, scope);
      return await compileObject(value, function, body, scope);
    }

    throw new ArgumentError(
        'Cannot compile ${ctx.runtimeType} to C yet!!!\n${ctx.span
            .highlight()}');
  }

  Future<c.Expression> compileObject(BonoboObject object,
      BonoboFunction function, List<c.Code> body, SymbolTable scope) async {
    throw new ArgumentError(
        'Cannot compile ${object.type.name} to C yet!!!\n${object.span
            .highlight()}');
  }
}

String removeQuotesFromString(String s) {
  if (s.length <= 1) return s;
  if (s.length == 2) return '';
  return s.substring(1, s.length - 1);
}
