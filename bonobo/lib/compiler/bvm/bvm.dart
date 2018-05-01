abstract class BVMOpcode {
  static const int
      // Stack
      POP = 0x0,
      PUSH = 0x1,

      // Control flow
      CALL = 0x3,
      RET = 0x4,

      // Memory
      ALLOCATE = 0x5,
      FREE = 0x6,

      // Math
      POW = 0x7,
      TIMES = 0x8,
      DIV = 0x9,
      MOD = 0xA,
      PLUS = 0xB,
      SUB = 0xC,

      // Moves
      MOV = 0xD;
}

abstract class BVMRegister {
  static const int EAX = 0,
      EBX = 1,
      ECX = 2,
      EDX = 3,
      ESI = 4,
      EDI = 5,
      EBP = 6,
      ESP = 7;
}
