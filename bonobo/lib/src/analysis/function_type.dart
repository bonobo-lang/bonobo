part of bonobo.src.analysis;

class BonoboFunctionType extends BonoboInheritedType {
  final List<BonoboType> parameters;

  final BonoboType returnType;

  BonoboFunctionType(this.parameters, this.returnType)
      : super('Function', BonoboType.Function$);
}
