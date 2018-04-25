set (CMAKE_CXX_STANDARD 11)
add_library(bvm_binary SHARED
    binary.h
    Constant.h
    Function.h
    Object.h
    Opcode.h
    Type.h
    parse_binary.h
    parse_binary.cc
)