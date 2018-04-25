part of bonobo.src.analysis;

class BonoboFunctionType extends BonoboInheritedType {
  final List<BonoboType> parameters;

  final BonoboType returnType;

  BonoboFunctionType(BonoboModule module, this.parameters, this.returnType)
      : super('Function', module, BonoboType.Function$);

  @override
  bool operator ==(other) {
    if (other is! BonoboFunctionType) return false;
    var o = other as BonoboFunctionType;

    // Compare parameters
    for (int i = 0; i < parameters.length; i++) {
      if (o.parameters.length < i + 1 || o.parameters[i] != parameters[i]) {
        return false;
      }
    }

    // Compare return type
    return o.returnType == returnType;
  }

  String get signature {
    var b = new StringBuffer('fn (');

    for (int i = 0; i < parameters.length; i++) {
      var p = parameters[i];

      if (i > 0) b.write(', ');
      b.write(p);
    }

    b.write(')');

    if (returnType != null) b.write(' => ${returnType.name}');

    return b.toString();
  }

  @override
  String toString() => signature;

  @override
  bool isAssignableTo(BonoboType other) {
    if (other is BonoboTypedef) return isAssignableTo(other.type);
    if (other is! BonoboFunctionType) return false;

    var o = other as BonoboFunctionType;

    if (o.parameters.length != parameters.length) return false;

    // Compare parameters
    for (int i = 0; i < parameters.length; i++) {
      if (!parameters[i].isAssignableTo(o.parameters[i])) {
        return false;
      }
    }

    return returnType.isAssignableTo(o.returnType);
  }
}
