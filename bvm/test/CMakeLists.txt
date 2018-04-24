find_package(GTest REQUIRED)
include_directories(${GTEST_INCLUDE_DIRS})
include_directories("${CMAKE_CURRENT_LIST_DIR}/../src")
add_subdirectory(jit)