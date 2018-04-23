part of bonobo.ir;

@Serializable(autoIdAndDateFields: false)
class _Type {
  _Span span;
  String name;
  _IdentifierType identifier;
  _TupleType tuple;
  _StructType struct;
  _FunctionType function;
}

@Serializable(autoIdAndDateFields: false)
class _IdentifierType {
  _Identifier identifier;
}

@Serializable(autoIdAndDateFields: false)
class _TupleType {
  List<_Type> items;
}

@Serializable(autoIdAndDateFields: false)
class _StructType {
  Map<String, _Type> fields;
}

@Serializable(autoIdAndDateFields: false)
class _FunctionType {
 List<_Type> parameters;
 _Type returnType;
}