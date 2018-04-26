#ifndef BVM_OPCODE_H
#define BVM_OPCODE_H

#include <cstdint>

namespace bvm
{
    enum class Opcode : uint8_t
    {
        // Functions
                POP_PARAM = 0x0,
        PUSH_PARAM = 0x1
    };
}

#endif
