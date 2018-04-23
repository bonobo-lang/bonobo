class Assembly {
  final List<Section> sections;
  Assembly({this.sections});
}

class Section {
  final String name;
  final Map<String, String> globals;
  final List<Allocation> allocations;
  final List<Instruction> instructions;

  Section({this.name, this.globals, this.allocations, this.instructions});
}

class Allocation {
  final String name, type, value;

  Allocation({this.name, this.type, this.value});
}

class Instruction {
  final String opcode;
  final List<String> arguments;

  Instruction({this.opcode, this.arguments});
}
