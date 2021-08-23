include (FetchContent)

FetchContent_Declare (gflags
    URL https://github.com/gflags/gflags/archive/refs/tags/v2.2.2.tar.gz
)
if (NOT gflags_POPULATED)
    FetchContent_Populate(gflags)
    add_subdirectory (${gflags_SOURCE_DIR}
        ${gflags_BINARY_DIR}
        EXCLUDE_FROM_ALL
    )
endif ()
