part of bonobo.compiler.ssa;

abstract class Block {
  String get label;
  Instruction get entry;
  int get size;
}

class BasicBlock extends Block {
  final String label;
  final Instruction entry;

  BasicBlock(this.label, this.entry);

  @override
  int get size => entry.totalSize;
}