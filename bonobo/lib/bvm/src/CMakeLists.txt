

# Get LLVM going
find_package(LLVM 5.0.0 REQUIRED CONFIG)

if (NOT ${LLVM_FOUND})
    message(FATAL_ERROR "LLVM 5.x is required to build Bonobo.")
endif()

include_directories(${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})
llvm_map_components_to_libnames(llvm_libs support core irreader)
add_subdirectory(binary)
add_subdirectory(jit)
