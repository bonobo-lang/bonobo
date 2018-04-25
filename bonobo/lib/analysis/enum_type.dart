part of bonobo.src.analysis;

/// TODO: Extend Int, instead of Num
class BonoboEnumType extends BonoboInheritedType {
  final List<BonoboEnumValue> values;

  BonoboEnumType(BonoboModule module, this.values) : super(null, module, BonoboType.Num);

  /// Finds the integer representation of the given name.
  int getValue(String name) {
    var value = values.firstWhere((v) => v.name == name);
    return value.index ?? values.indexOf(value);
  }

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

  @override
  String toString() {
    var b = new StringBuffer('{');

    for (int i = 0; i < values.length; i++) {
      if (i > 0) b.write(',');
      b.write(' ${values[i].name} = ${values[i].index ?? i}');
    }

    return b.toString() + '}';
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
