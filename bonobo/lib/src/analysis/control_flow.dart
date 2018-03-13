part of bonobo.src.analysis;

/// Represents a possible path that code can take through execution.
class ControlFlow {
  final List<ControlFlow> children = [];
  final List<StatementContext> statements = [];
  BonoboType _returnType;

  void set returnType(BonoboType value) {
    if (value != BonoboType.Root && value != null) {
      if (_returnType == null)
        _returnType = value;
      else
        _returnType = BonoboType.findCommonAncestor(_returnType, value);
    }
  }

  BonoboType get returnType {
    var returnTypes = <BonoboType>[];

    for (var child in children) {
      var returnType = child.returnType;
      if (returnType != null) returnTypes.add(returnType);
    }

    if (_returnType != null)
      returnTypes.add(_returnType);

    if (returnTypes.isNotEmpty)
      return returnTypes.reduce(BonoboType.findCommonAncestor);

    return null;
  }
}
