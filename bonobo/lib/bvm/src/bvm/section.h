//
// Created by Tobe on 5/1/18.
//

#ifndef PROJECT_SECTION_H
#define PROJECT_SECTION_H

#include <cstdint>

namespace bvm
{
    typedef struct
    {
        intptr_t length;
        uint8_t *data;
    } Section;
}


#endif //PROJECT_SECTION_H
