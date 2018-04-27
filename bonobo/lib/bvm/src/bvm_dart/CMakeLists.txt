set(CMAKE_CXX_STANDARD 11)

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

include_directories("${CMAKE_CURRENT_LIST_DIR}/..")
add_library(bvm_dart SHARED
        extension.h extension.cc
        dart_channel.cc dart_channel.h
        bvm_dart_dllmain_win.cc
        bvm_dart.h)
target_link_libraries(bvm_dart bvm)

if(WIN32)
    target_link_directories(bvm_dart ${DART_SDK}/bin/dart.lib)
endif()