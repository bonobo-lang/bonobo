part of bonobo.ir;

@Serializable(autoIdAndDateFields: false)
class _Statement {
  _ExpressionStatement expression;
  _VariableDeclarationStatement variableDeclaration;
}

@Serializable(autoIdAndDateFields: false)
class _ExpressionStatement {
  _Expression expression;
  bool isReturn;
}

@Serializable(autoIdAndDateFields: false)
class _VariableDeclarationStatement {
  List<_VariableDeclaration> variableDeclarations;
}

@Serializable(autoIdAndDateFields: false)
class _VariableDeclaration {
  _Identifier identifier;
  _Expression expression;
}