//
// Created by Tobe on 5/1/18.
//

#ifndef PROJECT_EXECUTABLE_H
#define PROJECT_EXECUTABLE_H

#include <vector>
#include "section.h"

namespace bvm
{
    typedef struct
    {
        std::vector<Section *> sections;
    } Executable;
}

#endif //PROJECT_EXECUTABLE_H
