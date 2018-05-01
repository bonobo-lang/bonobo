part of bonobo.compiler.ssa;

abstract class Block {
  String get label;
  Instruction get entry;
}

class BasicBlock extends Block {
  final String label;
  final Instruction entry;

  BasicBlock(this.label, this.entry);
}