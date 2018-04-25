#ifndef BVM_FUNCTIONSPEC_H
#define BVM_FUNCTIONSPEC_H
#include <stdint.h>
#include "Opcode.h"

namespace bvm {
    typedef struct Function {
        const char* name;
        uint8_t* parameters;
        char returnType;
        int64_t number_of_parameters, number_of_instructions;
        uint8_t * instructions;
        struct Function* next = nullptr;
    } Function;
}

#endif