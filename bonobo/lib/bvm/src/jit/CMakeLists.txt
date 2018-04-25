set(CMAKE_CXX_STANDARD 11)
add_library(bvm_jit SHARED
    BVM.h
    BVM.cc
    Continuation.h
    Frame.h
    JIT.h
    JIT.cc
    Trampoline.h
    extension.cc extension.h

)
target_link_libraries(bvm_jit bvm_binary ${llvm_libs})