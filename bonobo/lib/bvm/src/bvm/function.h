//
// Created by Tobe on 4/25/18.
//

#ifndef PROJECT_FUNCTION_H
#define PROJECT_FUNCTION_H

#include <cstdint>
#include <string>
#include "jit/dispatch.h"

namespace bvm
{
    typedef struct
    {
        char *name;
        uint8_t *bytecode;
        intptr_t length;
        JittedCode jit = nullptr;
        std::string *jitError = nullptr;
    } BVMFunction;
}

#endif //PROJECT_FUNCTION_H
