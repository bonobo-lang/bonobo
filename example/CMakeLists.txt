cmake_minimum_required(VERSION 2.4)
project(bonobo_examples)
set(BONOBO "bonobo")

macro("add_bonobo_executable" name srcs)
    add_custom_command(OUTPUT ${name}_bonobo
        COMMAND ${BONOBO} compile ${srcs}
    )
    add_custom_target(${name}
        DEPENDS ${name}_bonobo
        SOURCES ${srcs}
    )
endmacro()

add_bonobo_executable(hello hello.bnb)