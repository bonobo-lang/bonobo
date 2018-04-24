#ifndef BVM_OPCODE_H
#define BVM_OPCODE_H
#include <stdint.h>

namespace bvm {
  enum class Opcode: uint8_t {
    // Memory
    NEW,

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
    IF,
    ELIF,
    ELSE,
    CALL,
    RET,
    JMP,

    // Debugging, etc.
    THROW,
    SOURCE
  };
}

#endif
