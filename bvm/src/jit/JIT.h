#ifndef BVM_BASEJIT_H
#define BVM_BASEJIT_H
#include <stdint.h>
#include <stack>
#include <vector>
#include "../binary/binary.h"
#include "Continuation.h"
#include "Frame.h"
#include "Trampoline.h"

namespace bvm {
    class JIT {
        public:
            std::vector<void*> constants;
            std::vector<Continuation*> tasks;
            std::stack<Frame*> callStack;
            std::stack<void*> stack;
            Trampoline trampoline;
            void run(Object*);
    };
}

#endif