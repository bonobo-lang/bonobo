#ifndef BVM_TYPESPEC_H
#define BVM_TYPESPEC_H

namespace bvm {
    typedef struct Type {
        const char* name;
        uint8_t size;
        struct Type* next = nullptr;
    } Type;
}

#endif