//
// Created by Tobe on 4/25/18.
//

#ifndef PROJECT_BVM_TASK_H
#define PROJECT_BVM_TASK_H

#include <cstdint>
#include <stack>
#include <dart_native_api.h>
#include "Function.h"

namespace bvm
{
    class BVMTask
    {
    public:
        bool blocked = false;
        uint64_t returnTo;
        std::stack<void *> stack;
        intptr_t index = 0;
        BVMFunction *function;
        Dart_CObject *message;
        struct
        {
            intptr_t length;
            struct _Dart_CObject **values;
        } arguments;
    };
}


#endif //PROJECT_BVM_TASK_H
