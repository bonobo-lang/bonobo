part of 'analysis.dart';

class BonoboTupleType extends BonoboInheritedType {
  final List<BonoboType> types;
  String name;

  BonoboTupleType(BonoboModule module, this.types) : super(null, module) {
    name = '(${types.join(', ')})';
  }
}
