//
// Created by Tobe on 4/25/18.
//

#ifndef PROJECT_FUNCTION_H
#define PROJECT_FUNCTION_H

#include <cstdint>

namespace bvm {
    typedef struct {
        char* name;
        uint8_t* bytecode;
        intptr_t length;
    } BVMFunction;
}

#endif //PROJECT_FUNCTION_H
