part of bonobo.ir;

@Serializable(autoIdAndDateFields: false)
class _Module {
  String name;
  List<_Module> children;
  List<_Typedef> typedefs;
  List<_FunctionIR> functions;
}

@Serializable(autoIdAndDateFields: false)
class _Typedef {
  _Span span;
  _Identifier name;
  _Type type;
}

@Serializable(autoIdAndDateFields: false)
class _FunctionIR {
  _Span span;
  _Identifier name;
  List<_Parameter> parameters;
  _Type returnType;
  List<_Statement> body;
}

@Serializable(autoIdAndDateFields: false)
class _Parameter {
  _Span span;
  _Identifier name;
  _Type type;
}