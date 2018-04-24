#ifndef BVM_FRAME_H
#define BVM_FRAME_H

namespace bvm {
    typedef struct {
        const char* name;
        const char* file;
        int line;
        int column;
    } Frame;
}

#endif