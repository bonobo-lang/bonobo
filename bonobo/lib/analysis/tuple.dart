<<<<<<< HEAD:bonobo/lib/src/analysis/tuple.dart
part of bonobo.src.analysis;

class BonoboTupleType extends BonoboInheritedType {
  final List<BonoboType> types;
  String name;

  BonoboTupleType(this.types) : super(null) {
    name = '(${types.map((t) => t.toString()).join(', ')})';
  }
}
=======
part of bonobo.src.analysis;

class BonoboTupleType extends BonoboInheritedType {
  final List<BonoboType> types;
  String name;

  BonoboTupleType(this.types) : super(null) {
    name = '(${types.map((t) => t.name).join(', ')})';
  }
}
>>>>>>> 7ae4b23a50a45f8590a820e076523d7447a2e1d3:bonobo/lib/analysis/tuple.dart
