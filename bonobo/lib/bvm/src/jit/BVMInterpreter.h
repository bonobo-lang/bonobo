//
// Created by Tobe on 4/25/18.
//

#ifndef PROJECT_BVM_INTERPRETER_H
#define PROJECT_BVM_INTERPRETER_H

#include "bvm_task.h"

namespace bvm
{

    class BVMInterpreter {
        void visit(BVMTask* task);
    };

}

#endif //PROJECT_BVM_INTERPRETER_H
