include (FetchContent)

FetchContent_Declare (google_test
    URL https://github.com/google/googletest/archive/refs/tags/release-1.11.0.tar.gz
)
FetchContent_MakeAvailable(google_test)
