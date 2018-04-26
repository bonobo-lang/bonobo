cmake_minimum_required(VERSION 3.0)
set(${CMAKE_ARCHIVE_OUTPUT_DIRECTORY} "${CMAKE_CURRENT_LIST_DIR}/bin")
set(${CMAKE_LIBRARY_OUTPUT_DIRECTORY} "${CMAKE_CURRENT_LIST_DIR}/lib")
set(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} "${CMAKE_CURRENT_LIST_DIR}/bin")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
# Find Dart
set(DART_SDK $ENV{DART_SDK} CACHE STRING "The Dart SDK to build against.")

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
add_subdirectory(lib/bvm)