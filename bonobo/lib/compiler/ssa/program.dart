part of bonobo.compiler.ssa;

class Program {
  final List<Procedure> procedures = [];
  final Registers registers = new Registers();
}

class Registers {
  final Register accumulator = new Register(BVMRegister.EAX), // EAX
      secondaryAccumulator = new Register(BVMRegister.EBX), // EBX
      counter = new Register(BVMRegister.ECX), // ECX
      functionParameter = new Register(BVMRegister.EDX), // EDX
      pointer = new Register(BVMRegister.ESI), // ESI
      dataPointer = new Register(BVMRegister.EDI), // EDI
      basePointer = new Register(BVMRegister.EBP), // EBP
      stackPointer = new Register(BVMRegister.ESP); // ESP

  Register firstAvailable(int size) {
    return accumulator.checkAvailable(size) ??
        secondaryAccumulator.checkAvailable(size) ??
        counter.checkAvailable(size) ??
        functionParameter.checkAvailable(size) ??
        pointer.checkAvailable(size) ??
        dataPointer.checkAvailable(size) ??
        accumulator;
  }
}
