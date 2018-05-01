abstract class BVMOpcode {
  static const int
      // Functions
      POP_PARAM = 0x0,
      PUSH_PARAM = 0x1,

      // Data
      STRING = 0x2,

      // Control flow
      CALL = 0x3,
      RET = 0x4,

      // Printing + stringify
      PRINT = 0x5,
      UINT8_TO_STRING = 0x6,
      UINT16_TO_STRING = 0x7,
      UINT32_TO_STRING = 0x8,
      UINT64_TO_STRING = 0x9,
      DOUBLE_TO_STRING = 0xA,
      FLOAT_TO_STRING = 0xB,

      // More data, since I forgot to define earlier
      INT8 = 0xC,
      INT16 = 0xD,
      INT32 = 0xE,
      INT64 = 0xF,
      UINT8 = 0x10,
      UINT16 = 0x11,
      UINT32 = 0x12,
      UINT64 = 0x13,

      // Memory
      ALLOCATE = 0x14,
      FREE = 0x15,
      GET = 0x16,
      SET = 0x17,

      // Math. All arithmetic operations convert to double.
      POW = 0x18,
      TIMES = 0x19,
      DIV = 0x1A,
      MOD = 0x1B,
      PLUS = 0x1B,
      SUB = 0x1D,

      // Number conversions.
      CONVERT_UINT8 = 0x1E,
      CONVERT_UINT16 = 0x1F,
      CONVERT_UINT32 = 0x20,
      CONVERT_UINT64 = 0x21,
      CONVERT_INT8 = 0x22,
      CONVERT_INT16 = 0x23,
      CONVERT_INT32 = 0x24,
      CONVERT_INT64 = 0x25,
      CONVERT_FLOAT = 0x26,

      // Additional stringification, because I forgot.
      INT8_TO_STRING = 0x27,
      INT16_TO_STRING = 0x28,
      INT32_TO_STRING = 0x29,
      INT64_TO_STRING = 0x2A,

      // Variables
      GET_VARIABLE = 0x2B,
      SET_VARIABLE = 0x2C;
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
