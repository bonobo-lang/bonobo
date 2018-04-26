set(CMAKE_CXX_STANDARD 11)
SET(bvm_sources VM.h
        VM.cc
        frame.h
        trampoline.h
        function.h
        interpreter.cc
        interpreter.h
        opcode.h
        bvm_task.cc bvm_task.h bvm.h channel.cc channel.h)
add_library(bvm STATIC ${bvm_sources})
#add_library(bvm_shared SHARED ${bvm_sources})