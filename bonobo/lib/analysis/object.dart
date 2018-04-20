part of bonobo.src.analysis;

class BonoboObject {
  final List<SymbolUsage> usages = [];
  final BonoboType type;
  final FileSpan span;

  BonoboObject(this.type, this.span);

  String toString() {
    return '[Instance of ${type.name}]';
  }
}
