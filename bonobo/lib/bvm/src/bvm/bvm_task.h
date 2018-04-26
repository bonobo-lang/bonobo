//
// Created by Tobe on 4/25/18.
//

#ifndef PROJECT_BVM_TASK_H
#define PROJECT_BVM_TASK_H

#include <cstdint>
#include <stack>
#include <string>
#include <vector>
#include "function.h"

namespace bvm
{
    class BVMTask
    {
    public:
        bool blocked = false, started = false, functionRequested = false, success = false;
        const char *missingFunction = nullptr;
        BVMTask *returnTo = nullptr;
        std::stack<void *> *stack;
        std::stack<std::string> strings;
        std::string errorMessage;
        intptr_t index = 0;
        BVMFunction *function;
        std::vector<void *> parameters;
        intptr_t argc;
        void **argv;
        struct
        {
            intptr_t length;
            struct _Dart_CObject **values;
        } arguments;
    };
}


#endif //PROJECT_BVM_TASK_H
