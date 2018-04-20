part of bonobo.src.analysis;

class BonoboFunctionType extends BonoboInheritedType {
  final List<BonoboType> parameters;

  final BonoboType returnType;

  BonoboFunctionType(this.parameters, this.returnType)
      : super('Function', BonoboType.Function$);

  @override
  bool operator ==(other) {
    if (other is! BonoboFunctionType) return false;
    var o = other as BonoboFunctionType;

    // Compare parameters
    for (int i = 0; i < parameters.length; i++) {
      if (o.parameters.length < i + 1 || o.parameters[i] != parameters[i])
        return false;
    }

    // Compare return type
    return o.returnType == returnType;
  }

  String get signature {
    var b = new StringBuffer('f (');

    for (int i = 0; i < parameters.length; i++) {
      var p = parameters[i];

      if (i > 0) b.write(', ');
      b.write(': $p');
    }

    b.write(')');

    if (returnType != null) b.write(' => ${returnType.name}');

    return b.toString();
  }

  @override
  String toString() => signature;
}
