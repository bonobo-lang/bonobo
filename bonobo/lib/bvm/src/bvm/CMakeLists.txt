set(CMAKE_CXX_STANDARD 11)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
SET(bvm_sources VM.h
        VM.cc
        frame.h
        trampoline.h
        function.h
        interpreter.cc
        interpreter.h
        opcode.h
        bvm_task.cc bvm_task.h bvm.h channel.cc channel.h main.cc jit/jit.h jit/dispatch.h jit/print.cc)
add_library(bvm STATIC ${bvm_sources})
add_executable(bvm_cli main.cc)
target_link_libraries(bvm_cli bvm)
set_target_properties(bvm_cli PROPERTIES OUTPUT_NAME "bvm")