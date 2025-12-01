# The bulk of the source files are separated into a library for them to be testable.
add_library(%{name.lower}src INTERFACE # TODO: make static
    # Non-executable files go here
)
add_executable(%{name.lower} %{name.lower}/Main.cpp)

target_include_directories(%{name.lower}src INTERFACE ./) # TODO: make public

target_link_libraries(%{name.lower} %{name.lower}src)
# vim:ft=cmake
