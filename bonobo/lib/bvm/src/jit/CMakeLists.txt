set(CMAKE_CXX_STANDARD 11)
add_library(bvm_jit SHARED
    BVM.h
    BVM.cc
    Frame.h
    JIT.h
    JIT.cc
    Trampoline.h
    extension.cc extension.h
    Function.h BVMInterpreter.cc BVMInterpreter.h
    bvm_task.cc bvm_task.h)
target_include_directories(bvm_jit PUBLIC "${DART_SDK}\include")
message("Including Dart headers: ${DART_SDK}/include")
target_link_libraries(bvm_jit bvm_binary)# ${llvm_libs})
