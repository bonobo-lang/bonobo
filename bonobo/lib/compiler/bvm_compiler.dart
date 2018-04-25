import 'dart:async';
import 'dart:typed_data';

import 'package:bonobo/analysis/analysis.dart';
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

  Future<Uint8List> compileFunction(BonoboFunction function) async {
    var sink = new BinarySink();

    // Add all params
    sink..addUint8(BVMOpcode.NUM_PARAMS)..addUint8(function.parameters.length);

    for (var param in function.parameters)
      writeString(param.type.fullName, sink);

    return sink.toBytes();
  }
}
