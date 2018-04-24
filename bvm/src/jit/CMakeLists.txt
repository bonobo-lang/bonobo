set (CMAKE_CXX_STANDARD 11)
add_library(bvm_jit
    Continuation.h
    Frame.h
    JIT.h
    JIT.cc
    Trampoline.h
)