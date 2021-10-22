FetchContent_Declare (
    benchmark
    URL https://github.com/google/benchmark/archive/refs/tags/v1.5.5.tar.gz
)
if (NOT benchmark_POPULATED)
    FetchContent_Populate (benchmark)
    set (BENCHMARK_ENABLE_GTEST_TESTS OFF)
    set (BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "")
    add_subdirectory (${benchmark_SOURCE_DIR} ${benchmark_BINARY_DIR} EXCLUDE_FROM_ALL)
endif ()
