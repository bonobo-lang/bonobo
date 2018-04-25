part of 'analysis.dart';

class BonoboTupleType extends BonoboInheritedType {
  final List<BonoboType> types;
  String name;

  BonoboTupleType(this.types) : super(null) {
    name = '(${types.join(', ')})';
  }
}
