include (FetchContent)

# 从 flatbuffers 的仓库下载源码
FetchContent_Declare(flatbuffers
    GIT_REPOSITORY https://github.com/google/flatbuffers
    GIT_TAG v2.0.0
)
if (NOT flatbuffers_POPULATED)
    FetchContent_Populate(flatbuffers)
    set (FLATBUFFERS_BUILD_TESTS OFF)
    set (FLATBUFFERS_INSTALL OFF)
    add_subdirectory (${flatbuffers_SOURCE_DIR}
        ${flatbuffers_BINARY_DIR}
        EXCLUDE_FROM_ALL
    )
endif ()
