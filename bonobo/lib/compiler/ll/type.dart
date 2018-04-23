part of bonobo.compiler.ll;

@Serializable(autoIdAndDateFields: false)
class _Struct {
  String name;
  List<_Field> fields;
}

@Serializable(autoIdAndDateFields: false)
class _Field {
  String name;
  _Type type;
}

@Serializable(autoIdAndDateFields: false)
class _Type {
  String name;
  _PointerType pointer;
  _ArrayType array;
}

@Serializable(autoIdAndDateFields: false)
class _PointerType {
  _Type inner;
}

@Serializable(autoIdAndDateFields: false)
class _ArrayType {
  _Type inner;
  int size;
}