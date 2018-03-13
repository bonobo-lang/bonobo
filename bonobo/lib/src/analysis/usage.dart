part of bonobo.src.analysis;

class SymbolUsage {
  final SymbolUsageType type;
  final FileSpan span;

  SymbolUsage(this.type, this.span);
}

enum SymbolUsageType { declaration, read, write }
