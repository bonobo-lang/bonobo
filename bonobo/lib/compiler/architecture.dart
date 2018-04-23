/// Represents an abstract machine architecture, i.e. x86.
abstract class Architecture {
  Registers get registers;
}

abstract class Registers {
  Register get accumulator;
  Register get counter;
  Register get stackPointer;
}

abstract class Register {
  List<Register> get children;
  int get size;
}
