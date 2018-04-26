#ifndef BVM_OPCODE_H
#define BVM_OPCODE_H

#include <cstdint>

namespace bvm
{
    enum class Opcode : uint8_t
    {
        // Functions
                POP_PARAM = 0x0,
        PUSH_PARAM = 0x1,

        // Data
                STRING = 0x2,


        // Control Flow
                CALL = 0x3,
        RET = 0x4,

        // Printing + stringify
                PRINT = 0x5,
        CHAR_TO_STRING = 0x6,
        SHORT_TO_STRING = 0x7,
        INT_TO_STRING = 0x8,
        LONG_TO_STRING = 0x9,
        DOUBLE_TO_STRING = 0x10,
        FLOAT_TO_STRING = 0x11
    };
}

#endif
