part of bonobo.compiler.ssa;

class Register {
  final LinearMemory<RegisterValue> values = new LinearMemory(32);
  final Queue<MemoryBlock<RegisterValue>> spill = new Queue();
}

class RegisterValue {
  final RegisterValueType type;
  final int size;
  final FileSpan span;

  RegisterValue(this.type, this.size, this.span);
}

enum RegisterValueType { int8, int16, int32, string }
