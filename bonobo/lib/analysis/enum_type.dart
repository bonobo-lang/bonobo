part of bonobo.src.analysis;

/// TODO: Extend Int, instead of Num
class BonoboEnumType extends BonoboInheritedType {
  final List<BonoboEnumValue> values;

  BonoboEnumType(this.values) : super(null, BonoboType.Num);

  @override
  bool operator ==(other) {
    if (other is! BonoboEnumType) return false;
    return const ListEquality<BonoboEnumValue>().equals(values, other.values);
  }

  @override
  bool isAssignableTo(BonoboType other) {
    return other is BonoboEnumType
        ? this == other
        : super.isAssignableTo(other);
  }
}

class BonoboEnumValue {
  final String name;
  final int index;

  BonoboEnumValue(this.name, this.index);

  @override
  bool operator ==(other) {
    return other is BonoboEnumValue &&
        other.name == name &&
        other.index == index;
  }
}
