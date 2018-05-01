part of bonobo.compiler.ssa;

class Procedure {
  final List<Block> blocks = [];
  final String name;

  Procedure(this.name);

  Block get mainBlock =>
      blocks.firstWhere((b) => b.label == 'entry', orElse: () => null);
}
