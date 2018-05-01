//
// Created by Tobe on 4/30/18.
//

#ifndef PROJECT_VALUE_H
#define PROJECT_VALUE_H

#include <cstdint>
namespace bvm
{
    enum ValueType
    {
        BYTE,
        STRING
    };

    typedef struct
    {
        ValueType type;
        union
        {
            uint8_t byteValue;
            const char *stringValue;
        };
    } Value;
}

#endif //PROJECT_VALUE_H
