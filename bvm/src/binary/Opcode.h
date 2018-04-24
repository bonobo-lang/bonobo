#ifndef BVM_OPCODE_H
#define BVM_OPCODE_H

namespace bvm {
  enum Opcode {
    // Memory
    NEW ,

    // Stack
    PUSH,
    POP,

    // Math
    POW,
    MUL,
    DIV,
    MOD,
    ADD,
    SUB,

    // Control flow
    IF
    ELIF,
    ELSE,

    // Debugging, etc.
    THROW,
    SOURCE
  };
}

#endif
