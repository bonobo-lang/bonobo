#ifndef BVM_CONSTANTSPEC_H
#define BVM_CONSTANTSPEC_H

#include <stdint.h>

namespace bvm
{
    typedef struct Constant
    {
        const char *name;
        uint64_t size;
        void *value;
        struct Constant *next = nullptr;
    } Constant;
}

#endif
