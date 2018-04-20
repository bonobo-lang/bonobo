part of bonobo.src.analysis;

/// Represents a standalone unit of Bonobo code.
class BonoboModule {
  static Map<Uri, BonoboModule> _singletons = {};
  final List<BonoboModule> children = [];
  final Map<Uri, UnitContext> compilationUnits = {};
  final Map<String, BonoboType> types = {};
  final Directory directory;
  final bool isCore;
  final BonoboModuleSystem moduleSystem;
  final BonoboModule parent;
  final SymbolTable<BonoboObject> scope = new SymbolTable();
  BonoboAnalyzer analyzer;
  FileSpan emptySpan;
  String _fullName, _name;

  BonoboModule.__(this.directory, this.parent, [BonoboModuleSystem system])
      : isCore = false,
        moduleSystem = system ?? parent?.moduleSystem {
    if (parent != null && !parent.children.contains(this))
      parent.children.add(this);
  }

  factory BonoboModule._(Directory directory, BonoboModule parent,
      [BonoboModuleSystem system]) {
    return _singletons.putIfAbsent(directory.absolute.uri, () {
      return new BonoboModule.__(directory, parent, system);
    });
  }

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

  @override
  bool operator ==(other) {
    return other is BonoboModule &&
        other.directory.absolute.path == directory.absolute.path;
  }
}