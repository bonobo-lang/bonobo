part of bonobo.ir;

@Serializable(autoIdAndDateFields: false)
class _Identifier {
  List<String> namespaces;
  String name;
}

@Serializable(autoIdAndDateFields: false)
class _Expression {
  _Span span;
  var literal;
  _Identifier identifier;
  _BinaryExpression binary;
  _ObjectExpression object;
  _TupleExpression tuple;
}

@Serializable(autoIdAndDateFields: false)
class _BinaryExpression {
  _Expression left, right;
  String op;
}

@Serializable(autoIdAndDateFields: false)
class _TupleExpression {
  List<_Expression> items;
}

@Serializable(autoIdAndDateFields: false)
class _ObjectExpression {
  List<_KeyValuePair> keyValuePairs;
}

@Serializable(autoIdAndDateFields: false)
class _KeyValuePair {
  _Expression key, value;
}
