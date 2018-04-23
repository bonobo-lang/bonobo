part of bonobo.compiler.ll;

@Serializable(autoIdAndDateFields: false)
class _CompilationUnit {
  List<_Typedef> typedefs;
  List<_Enum> enums;
  List<_FunctionLL> functions;
}

@Serializable(autoIdAndDateFields: false)
class _Typedef {
  String name;
  _Type type;
}

@Serializable(autoIdAndDateFields: false)
class _Enum {
  String name;
  List<String> values;
}

@Serializable(autoIdAndDateFields: false)
class _FunctionLL {
  String name;
  List<_Parameter> parameters;
  _Type returnType;
  List<_Statement> body;
}

@Serializable(autoIdAndDateFields: false)
class _Parameter {
  String name;
  _Type type;
}