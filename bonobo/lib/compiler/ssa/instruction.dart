part of bonobo.compiler.ssa;

abstract class Instruction {
  FileSpan get span;

  DominanceFrontier get dominanceFrontier;

  int get size;

  int get totalSize => size + dominanceFrontier.size;
}

class SimpleInstruction extends Instruction {
  final List<int> operands = [];
  final int opcode;
  final FileSpan span;
  final DominanceFrontier dominanceFrontier;

  SimpleInstruction(this.opcode, this.span, this.dominanceFrontier);

  @override
  int get size => 1 + operands.length * 1;
}
