#ifndef BVM_CONTINUATION_H
#define BVM_CONTINUATION_H

#include <cstdint>
#include <stack>
#include <dart_api.h>

namespace bvm
{
    class BVMTask
    {
    public:
        bool blocked = false;
        uint8_t *bytecode;
        uint64_t returnTo;
        std::stack<void *> stack;
        int64_t index = 0;

        struct
        {
            intptr_t length;
            struct _Dart_CObject **values;
        } arguments;
    };
}

#endif