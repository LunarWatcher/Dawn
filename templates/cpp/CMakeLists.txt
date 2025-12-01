cmake_minimum_required(VERSION 3.10)
project(%{name})

set (CMAKE_CXX_STANDARD 20)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

add_subdirectory(src)
add_subdirectory(tests EXCLUDE_FROM_ALL)

add_custom_target(run
    COMMAND %{name.lower}
    DEPENDS %{name.lower}
    COMMENT "Run %{name}")
add_custom_target(test
    COMMAND tests
    DEPENDS tests
    COMMENT "Test %{name}")
# vim:ft=cmake
