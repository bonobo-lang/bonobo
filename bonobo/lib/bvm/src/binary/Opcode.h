#ifndef BVM_OPCODE_H
#define BVM_OPCODE_H

#include <cstdint>

namespace bvm
{
    enum class Opcode : uint8_t
    {
        // Functions
                NUM_PARAMS = 0x0,
        PARAM_TYPE = 0x1,
    };
}

#endif
