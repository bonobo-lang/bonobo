part of bonobo.compiler.ssa;

class DominanceFrontier {
  final SymbolTable<RegisterValue> _scope;
  final List<Instruction> instructions = [];

  DominanceFrontier() : _scope = new SymbolTable();

  DominanceFrontier._child(DominanceFrontier parent)
      : _scope = parent._scope.createChild();

  int get size => instructions.isEmpty
      ? 0
      : instructions.map((i) => i.totalSize).reduce((a, b) => a + b);
}
