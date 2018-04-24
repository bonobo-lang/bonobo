#ifndef BVM_OPCODE_H
#define BVM_OPCODE_H

#include <stdint.h>

namespace bvm
{
    enum class Opcode : uint8_t
    {
        // Constants
                CONSTANT8,
        CONSTANT16,
        CONSTANT32,
        CONSTANT64,
        CONSTANT128,

        // Memory
                GET_CONSTANT,
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
