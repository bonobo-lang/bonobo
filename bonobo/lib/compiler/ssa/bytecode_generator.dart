part of bonobo.compiler.ssa;

class BytecodeGenerator {
  const BytecodeGenerator();

  void generate(Program program, SSACompilerState state, BinarySink sink) {
    var magic = BVMOpcode.MAGIC, idx = 0, checksum = (magic % (idx + 1)) >> 2;
    sink..addInt32(magic)..addInt32(idx)..addInt32(checksum);

    // Generate .data section
    var dataSection = generateDataSection(program, state).toBytes();
    sink.copy(dataSection);

    // Generate .text section
    var textSection = generateTextSection(program, state).toBytes();
    sink.copy(textSection);
  }

  BinarySink generateDataSection(Program program, SSACompilerState state) {
    var sink = new BinarySink();
    var section = sink.toBytes();
    return new BinarySink(size: 10)
      ..addUint8(BVMOpcode.SECTION)
      ..addUint8(BVMOpcode.DATA_SECTION)
      ..addUint64(section.length)
      ..copy(section);
  }

  BinarySink generateTextSection(Program program, SSACompilerState state) {
    var sink = new BinarySink();

    for (var proc in program.procedures) {
      var procSink = new BinarySink();

      for (var block in proc.blocks) {
        var blockSink = new BinarySink();

        Instruction instruction = block.entry;

        while (instruction != null) {
          if (instruction is BasicInstruction) {
            blockSink.addUint8(instruction.opcode);
            instruction.operands.forEach(blockSink.addUint8);
          }

          instruction = instruction.dominanceFrontier.next;
        }

        // TODO: Compute block sizes
        procSink.copy(blockSink.toBytes());
      }

      sink.copy(procSink.toBytes());
    }

    var section = sink.toBytes();
    return new BinarySink(size: 10)
      ..addUint8(BVMOpcode.SECTION)
      ..addUint8(BVMOpcode.TEXT_SECTION)
      ..addUint64(section.length)
      ..copy(section);
  }
}
