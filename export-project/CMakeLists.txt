cmake_minimum_required(VERSION 3.16)

project (export-project)

add_library (lib1 STATIC src/lib1.h src/lib1.cpp)

install (TARGETS lib1 EXPORT lib1Targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

include (CMakePackageConfigHelpers)
write_basic_package_version_file (
    libConfigVersion.cmake
    VERSION 0.0.1
    COMPATIBILITY AnyNewerVersion
)
install (EXPORT lib1Targets
    FILE lib1Targets.cmake
    NAMESPACE lib1::
    DESTINATION lib1/cmake/lib1
)