abstract class BVMOpcode {
  static const int
      // Functions
      POP_PARAM = 0x0,
      PUSH_PARAM = 0x1,

      // Data
      STRING = 0x2,

      // Control flow
      CALL = 0x3,
      RET = 0x4;
}
