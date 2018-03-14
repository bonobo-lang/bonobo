part of bonobo.src.tuples;

class BonoboTupleType extends BonoboInheritedType {
  final List<BonoboType> types;
  String name;

  BonoboTupleType(this.types) : super(null) {
    name = '(${types.map((t) => t.name).join(', ')})';
  }
}
