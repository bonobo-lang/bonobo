#ifndef BVM_FUNCTIONSPEC_H
#define BVM_FUNCTIONSPEC_H

namespace bvm {
    typedef struct {
        const char* name;
        char* parameters;
        char returnType;
        int number_of_parameters;
    } Function;
}

#endif