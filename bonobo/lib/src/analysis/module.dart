part of bonobo.src.analysis;

/// Represents a standalone unit of Bonobo code.
class BonoboModule {
  final List<BonoboModule> children = [];
  final List<CompilationUnitContext> compilationUnits = [];
  final Directory directory;
  final BonoboModuleSystem moduleSystem;
  final BonoboModule parent;
  SymbolTable<BonoboObject> scope;
  String _fullName, _name;

  BonoboModule._(this.directory, this.parent)
      : moduleSystem = parent.moduleSystem;

  BonoboModule._root(this.directory, this.moduleSystem) : parent = null;

  bool get isRoot => parent == null;

  String get name => _name ??= p.basenameWithoutExtension(directory.path);

  String get fullName {
    if (_fullName != null) return _fullName;
    var names = <String>[];
    var module = this;

    while (module != null) {
      names.insert(0, module.name);
      module = module.parent;
    }

    return _fullName = names.join('.');
  }
}
