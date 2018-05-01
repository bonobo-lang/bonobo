//
// Created by Tobe on 4/30/18.
//

#ifndef PROJECT_REGISTER_H
#define PROJECT_REGISTER_H

#include "value.h"

namespace bvm
{
    typedef struct Register
    {
        Value *value = nullptr;
    };
}

#endif //PROJECT_REGISTER_H
