#ifndef BVM_TYPESPEC_H
#define BVM_TYPESPEC_H

namespace bvm {
    typedef struct {
        const char* name;
        int size;
    } Type;
}

#endif