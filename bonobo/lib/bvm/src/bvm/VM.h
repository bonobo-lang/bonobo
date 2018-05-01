//
// Created by Tobe on 5/1/18.
//

#ifndef PROJECT_VM_H
#define PROJECT_VM_H

#include "register.h"

namespace bvm
{
    class VM
    {
    public:
        VM();
        Register *registers;
    };
}

#endif //PROJECT_VM_H
