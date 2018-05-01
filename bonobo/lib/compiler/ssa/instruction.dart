part of bonobo.compiler.ssa;

abstract class Instruction {
  FileSpan get span;

  DominanceFrontier get dominanceFrontier;

  int get size;

  int get totalSize => size + dominanceFrontier.size;
}

class BasicInstruction extends Instruction {
  final int opcode;
  final List<int> operands;
  final FileSpan span;
  final DominanceFrontier dominanceFrontier;

  BasicInstruction(
      this.opcode, this.operands, this.span, this.dominanceFrontier);

  @override
  int get size => 1 + operands.length * 1;
}
