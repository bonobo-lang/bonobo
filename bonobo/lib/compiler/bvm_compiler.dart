import 'dart:async';
import 'dart:typed_data';

import 'package:bonobo/analysis/analysis.dart';
import 'package:bonobo/ast/ast.dart';
import 'package:bonobo/util/util.dart';
import 'package:symbol_table/symbol_table.dart';
import 'bvm/bvm.dart';
import 'base_compiler.dart';

class BVMCompiler implements BonoboCompiler<Uint8List> {
  const BVMCompiler();

  @override
  Uint8List compile(BonoboModule module) {
    var sink = new BinarySink();

    // Write the magic: 0xB090B0
    // Then a random number. Let's just say 1337.
    // Then the "checksum": (magic % arbitrary) >> 2
    var magic = 0xB090B0, arbitrary = 1337, checksum = (magic % arbitrary) >> 2;
    sink..addInt32(magic)..addInt32(arbitrary)..addInt32(checksum);

    // TODO: All constants

    // TODO: All types

    // TODO: All functions

    // Return the created binary.
    return sink.toBytes();
  }

  void writeString(String str, BinarySink sink) {
    // Write length as long, then the string, then '\0'
    sink
      ..addUint64(str.length + 1)
      ..write(str);
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

    // Add all params
    for (var param in function.parameters)
      // BVM expects the PARAM opcode, which pops from the stack into a parameter.
      sink.addUint8(BVMOpcode.POP_PARAM);

    await compileControlFlow(
        module, function.body, function.scope, function, sink);

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
          .resolve(ctx.target, function, function.scope);
      pushString((target as BonoboFunction).fullName, sink);

      // Push CALL
      sink.addUint8(BVMOpcode.CALL);
    } else {
      throw 'Unsupported statement: ${ctx.runtimeType}\n${ctx.span
          .highlight()}';
    }
  }
}
