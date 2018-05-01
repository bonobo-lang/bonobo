part of bonobo.compiler.ssa;

class DominanceFrontier {
  final SymbolTable<RegisterValue> _scope;
  Instruction next;

  DominanceFrontier() : _scope = new SymbolTable();

  DominanceFrontier._child(DominanceFrontier parent)
      : _scope = parent._scope.createChild();

  DominanceFrontier createChild() => new DominanceFrontier._child(this);

  int get size => next?.size ?? 0;
}
