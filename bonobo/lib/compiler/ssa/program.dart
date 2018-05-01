part of bonobo.compiler.ssa;

class Program {
  final List<Procedure> procedures = [];
  final Registers registers = new Registers();
}

class Registers {
  final Register accumulator = new Register(), // EAX
      secondaryAccumulator = new Register(), // EBX
      counter = new Register(), // ECX
      functionParameter = new Register(), // EDX
      pointer = new Register(), // ESI
      dataPointer = new Register(), // EDI
      basePointer = new Register(), // EBP
      stackPointer = new Register(); // ESP
}
