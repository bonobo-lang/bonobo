part of bonobo.compiler.ll;

@Serializable(autoIdAndDateFields: false)
class _Statement {
  _ExpressionStatement expression;
}

@Serializable(autoIdAndDateFields: false)
class _ExpressionStatement {
  bool isReturn;
}