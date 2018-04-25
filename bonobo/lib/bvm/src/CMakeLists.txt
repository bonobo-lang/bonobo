set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Find Dart
set(DART_SDK $ENV{DART_SDK})

if (${DART_SDK} STREQUAL "")
    message(FATAL_ERROR "You must set the `DART_SDK` environment variable to the path of the Dart SDK.")
else ()
    message("Building against Dart SDK: ${DART_SDK}")
endif ()

include_directories(${DART_SDK}/include)
add_definitions(-DDART_SHARED_LIB=1)

# OS-specific flags
if (${APPLE})
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -undefined dynamic_lookup")
endif ()

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
