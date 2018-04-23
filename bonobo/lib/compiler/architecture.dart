import 'package:code_buffer/code_buffer.dart';
import 'asm.dart';

/// Represents an abstract machine architecture, i.e. x86.
abstract class Architecture {
  Registers get registers;
  void compile(Assembly assembly, CodeBuffer buffer);
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
