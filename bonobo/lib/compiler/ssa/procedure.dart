part of bonobo.compiler.ssa;

class Procedure {
  final List<Block> blocks = [];
  final String name;
  MemoryBlock location;

  Procedure(this.name);

  Block get mainBlock =>
      blocks.firstWhere((b) => b.label == 'entry', orElse: () => null);

  int get size => blocks.isEmpty ? 0 : blocks.map((b) => b.size).reduce((a, b) => a + b);
}
