part of bonobo.compiler.ssa;

class Register {
  final LinearMemory<RegisterValue> values = new LinearMemory(32);
  final Queue<List<MemoryBlock<RegisterValue>>> spill = new Queue();
  final int index;
  final List<MemoryBlock<RegisterValue>> _currentBlocks = [];

  Register(this.index);

  Register checkAvailable(int size) {
    var block = values.allocate(size);
    if (block == null) return null;
    block.release();
    return this;
  }

  MemoryBlock<RegisterValue> set(RegisterValue value,
      void Function(List<MemoryBlock<RegisterValue>>) onSpill) {
    var size = value.size;
    var block = values.allocate(size, value);

    if (block != null) {
      value.register = this;
      _currentBlocks.add(block);
      return block;
    } else {
      // Spill current values into memory
      var toSpill = new List<MemoryBlock>.from(_currentBlocks);
      onSpill(toSpill);
      toSpill.forEach((b) => b.release());
      spill.addFirst(toSpill);
      _currentBlocks.clear();

      // Now, allocate the block.
      var block = values.allocate(size, value);
      value.register = this;
      _currentBlocks.add(block);
      return block;
    }
  }
}

class RegisterValue {
  final RegisterValueType type;
  final int size;
  final FileSpan span;
  Register register;

  RegisterValue(this.type, this.size, this.span);
}

enum RegisterValueType { int8, int16, int32, string }
