cmake_minimum_required(VERSION 2.4)
project(bonobo_examples)
set(BONOBO pub global run bonobo)
set(CMAKE_BUILD_TYPE Debug)
set(RUNTIME_DIR ${PROJECT_SOURCE_DIR}/../bonobo/runtime)

# Build the Bonobo runtime.
add_library(bonobo_runtime
    "${RUNTIME_DIR}/error.c"
    "${RUNTIME_DIR}/string.c"
)
include_directories(${RUNTIME_DIR})

# Simple macro to build a Bonobo program to native code.
macro("add_bonobo_executable" name)
    add_custom_command(OUTPUT ${name}_bonobo_cmd
        COMMAND ${BONOBO} compile -o ${name}.c ${name}.bnb
    )
    add_custom_target(${name}_bonobo DEPENDS ${name}_bonobo_cmd)
    add_executable(${name} ${name}.c)
    add_dependencies(${name} ${name}_bonobo)
    target_link_libraries(${name} bonobo_runtime)
endmacro()

# Build `hello.bnb`, etc.
add_bonobo_executable(hello)
add_bonobo_executable(functions)