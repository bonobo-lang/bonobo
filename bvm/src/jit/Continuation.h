#ifndef BVM_CONTINUATION_H
#define BVM_CONTINUATION_H
#include <stdint.h>
#include <stack>

namespace bvm {
    class Continuation {
        public:
            uint64_t returnTo;
            std::stack<void*> stack;
    };
}

#endif