part of bonobo.src.analysis;

class BonoboObject {
  final List<SymbolUsage> usages = [];
  final BonoboType type;
  final FileSpan span;

  BonoboObject(this.type, this.span);
}