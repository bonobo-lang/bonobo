import 'dart:async';
import 'dart:typed_data';

import 'package:bonobo/analysis/analysis.dart';
import 'package:bonobo/ast/ast.dart';
import 'package:bonobo/util/util.dart';
import 'package:symbol_table/symbol_table.dart';
import 'bvm/bvm.dart';
import 'base_compiler.dart';

class BVMCompiler implements BonoboCompiler<Future<Uint8List>> {
  const BVMCompiler();

  @override
  Future<Uint8List> compile(BonoboModule module) async {
    var sink = new BinarySink();

    // TODO: All constants

    // TODO: All types

    // TODO: All functions
    var codeSink = new BinarySink();
    List<BonoboFunction> allFunctions = module.analyzer.allReferencedObjects
        .where((o) => o is BonoboFunction)
        .toList();
    codeSink.addUint64(allFunctions.length);

    for (var function in allFunctions) {
      var bytecode = await compileFunction(module, function);

      codeSink
        ..write(function.fullName)
        ..addUint64(bytecode.length)
        ..copy(bytecode);
    }

    // Write the magic: 0xB090B0
    // Then the index at which the main function occurs.
    // Then the "checksum": (magic % idx) >> 2
    var magic = 0xB090B0,
        idx = allFunctions.indexOf(module.mainFunction),
        checksum = (magic % (idx + 1)) >> 2;
    sink..addInt32(magic)..addInt32(idx)..addInt32(checksum);

    sink.copy(codeSink.toBytes());

    // Return the created binary.
    return sink.toBytes();
  }

  void pushString(String str, BinarySink sink) {
    sink.addUint8(BVMOpcode.STRING);
    for (var ch in str.codeUnits) sink.addUint8(ch);
    //for (int i = str.length - 1; i >= 0; i--) sink.addUint8(str.codeUnitAt(i));
    sink.addUint8(0);
  }

  Future<Uint8List> compileFunction(
      BonoboModule module, BonoboFunction function) async {
    var sink = new BinarySink();

    if (function is BonoboNativeFunction) {
      await function.compile(sink);
    } else {
      // Add all params
      for (var param in function.parameters)
        // BVM expects the PARAM opcode, which pops from the stack into a parameter.
        sink.addUint8(BVMOpcode.POP_PARAM);

      await compileControlFlow(
          module, function.body, function.scope, function, sink);
    }

    return sink.toBytes();
  }

  Future compileControlFlow(
      BonoboModule module,
      ControlFlow body,
      SymbolTable<BonoboObject> scope,
      BonoboFunction function,
      BinarySink sink) async {
    // TODO: Compile each statement
    for (var ctx in body.statements) {
      if (ctx is ExpressionStatementContext) {
        await compileExpression(
            module, ctx.expression, body, scope, function, sink);
      } else if (ctx is ReturnStatementContext) {
        await compileExpression(
            module, ctx.expression, body, scope, function, sink);
        sink.addUint8(BVMOpcode.RET);
      } else {
        throw 'Unsupported statement: ${ctx.runtimeType}\n${ctx.span
            .highlight()}';
      }
    }
  }

  Future compileExpression(
      BonoboModule module,
      ExpressionContext ctx,
      ControlFlow body,
      SymbolTable<BonoboObject> scope,
      BonoboFunction function,
      BinarySink sink) async {
    // Literals
    if (ctx is StringLiteralContext) return pushString(ctx.constantValue, sink);

    //
    if (ctx is CallExpressionContext) {
      // Push arguments in reverse order
      for (int i = ctx.arguments.expressions.length - 1; i >= 0; i--)
        await compileExpression(
            module, ctx.arguments.expressions[i], body, scope, function, sink);

      // Push name of function
      var target = await module.analyzer.expressionAnalyzer
          .resolve(ctx.target, function, function.scope) as BonoboFunction;

      if (target is BonoboNativeFunction)
        await target.compile(sink);
      else
        pushString(target.fullName, sink);

      // Push CALL
      sink.addUint8(BVMOpcode.CALL);
    } else {
      throw 'Unsupported statement: ${ctx.runtimeType}\n${ctx.span
          .highlight()}';
    }
  }
}
