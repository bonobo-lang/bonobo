part of bonobo.src.analysis;

/// Represents a standalone unit of Bonobo code.
class BonoboModule {
  final List<BonoboModule> children = [];
  final Map<Uri, CompilationUnitContext> compilationUnits = {};
  final Map<String, BonoboType> types = {};
  final Directory directory;
  final bool isCore;
  final BonoboModuleSystem moduleSystem;
  final BonoboModule parent;
  SymbolTable<BonoboObject> scope = new SymbolTable();
  String _fullName, _name;

  BonoboModule._(this.directory, this.parent)
      : isCore = false,
        moduleSystem = parent.moduleSystem;

  BonoboModule._core(this.directory, this.moduleSystem)
      : isCore = true,
        parent = null;

  bool get isRoot => parent == null;

  String get name => _name ??= p.basenameWithoutExtension(directory.path);

  String get fullName {
    if (_fullName != null) return _fullName;
    var names = <String>[];
    var module = this;

    while (module != null && !module.isCore) {
      names.insert(0, module.name);
      module = module.parent;
    }

    return _fullName = names.join('.');
  }
}
