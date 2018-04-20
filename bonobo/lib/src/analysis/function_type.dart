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

    // Compare name
    if (o.name != name) return false;

    // Compare span
    if (o.span != span) return false;

    // Compare parameters
    for (int i = 0; i < parameters.length; i++) {
      if (o.parameters.length < i + 1 || o.parameters[i] != parameters[i])
        return false;
    }

    // Compare return type
    return o.returnType == returnType;
  }
}
