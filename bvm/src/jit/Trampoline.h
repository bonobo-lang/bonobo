#ifndef BVM_TRAMPOLINE_H
#define BVM_TRAMPOLINE_H
#include <stdint.h>

namespace bvm {
    class Trampoline {
        public:
            const char* currentFunction;
            uint64_t currentFunctionOffset;
    };
}

#endif