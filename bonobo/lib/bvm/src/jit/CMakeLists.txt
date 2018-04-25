set(CMAKE_CXX_STANDARD 11)
add_library(bvm_jit
    BVM.h
    BVM.cc
    Continuation.h
    Frame.h
    JIT.h
    JIT.cc
    Trampoline.h
)
target_link_libraries(bvm_jit ${llvm_libs})