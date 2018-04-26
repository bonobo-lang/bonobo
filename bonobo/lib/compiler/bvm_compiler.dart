import 'dart:async';
import 'dart:typed_data';

import 'package:bonobo/analysis/analysis.dart';
import 'package:bonobo/ast/ast.dart';
import 'package:bonobo/util/util.dart';
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
    for (int i = str.length - 1; i >= 0; i--) sink.addUint8(str.codeUnitAt(i));
    sink.addUint8(0);
    sink.addUint8(BVMOpcode.STRING);
  }

  Future<Uint8List> compileFunction(BonoboFunction function) async {
    var sink = new BinarySink();

    // Add all params
    for (var param in function.parameters)
      // BVM expects the PARAM opcode, which pops from the stack into a parameter.
      sink.addUint8(BVMOpcode.POP_PARAM);

    await compileControlFlow(function.body, function, sink);

    return sink.toBytes();
  }

  Future compileControlFlow(
      ControlFlow body, BonoboFunction function, BinarySink sink) async {
    // TODO: Compile each statement
    for (var ctx in body.statements) {
      if (ctx is ExpressionStatementContext) {
        await compileExpression(ctx.expression, body, function, sink);
      } else if (ctx is ReturnStatementContext) {
        await compileExpression(ctx.expression, body, function, sink);
        sink.addUint8(BVMOpcode.RET);
      } else {
        throw 'Unsupported statement: ${ctx.runtimeType}\n${ctx.span
            .highlight()}';
      }
    }
  }

  Future compileExpression(ExpressionContext ctx, ControlFlow body,
      BonoboFunction function, BinarySink sink) async {
    // Literals
    if (ctx is StringLiteralContext) return pushString(ctx.constantValue, sink);

    //
    if (ctx is CallExpressionContext) {
      // Push arguments in reverse order
      for (int i = ctx.arguments.expressions.length - 1; i >= 0; i--)
        await compileExpression(
            ctx.arguments.expressions[i], body, function, sink);

      // Push name of function
      pushString(function.fullName, sink);

      // Push CALL
      sink.addUint8(BVMOpcode.CALL);
    } else {
      throw 'Unsupported statement: ${ctx.runtimeType}\n${ctx.span
          .highlight()}';
    }
  }
}
