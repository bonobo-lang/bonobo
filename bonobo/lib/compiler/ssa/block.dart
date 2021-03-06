part of bonobo.compiler.ssa;

abstract class Block {
  String get label;
  Instruction get entry;
  int get size;
  void set entry(Instruction value);
}

class BasicBlock extends Block {
  final String label;
  Instruction entry;

  BasicBlock(this.label);

  @override
  int get size => entry?.totalSize ?? 0;
}