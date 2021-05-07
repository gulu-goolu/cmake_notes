cmake_minimum_required(VERSION 3.20)
project(example1)

# 静态链接
add_library(lib1 STATIC lib.h lib.cpp)
add_executable(demo1 demo.cpp)
target_link_libraries(demo1 lib1)

# 动态链接
add_library(lib2 SHARED lib.h lib.cpp)
add_executable(demo2 demo.cpp)
target_link_libraries(demo2 lib2)

# 静态库 + 静态库
add_library(base3 STATIC base.cpp)
add_library(lib3 STATIC lib.cpp)
target_link_libraries(lib3 base3)
add_executable(demo3 demo.cpp)
target_link_libraries(demo3 lib3)

# base.so + lib.a
add_library(base4 SHARED base.cpp)
add_library(lib4 STATIC lib.cpp)
target_link_libraries(lib4 base4)
add_executable(demo4 demo.cpp)
target_link_libraries(demo4 lib4)

# 动态库 + 动态库
add_library(base5 SHARED base.cpp)
add_library(lib5 SHARED lib.cpp)
target_link_libraries(lib5 base5)
add_executable(demo5 demo.cpp)
target_link_libraries(demo5 lib5)

# base.a + lib.so
add_library(base6 STATIC base.cpp)
add_library(lib6 SHARED lib.cpp)
target_link_libraries(lib6 base6)
add_executable(demo6 demo.cpp)
target_link_libraries(demo6 lib6)

# 不显示指定
add_library(base7 base.cpp)
add_library(lib7 lib.cpp)
target_link_libraries(lib7 base7)
add_executable(demo7 demo.cpp)
target_link_libraries(demo7 lib7)

# 显示指定其中一个
add_library(base8 base.cpp)
add_library(lib8 SHARED lib.cpp)
target_link_libraries(lib8 base8)
add_executable(demo8 demo.cpp)
target_link_libraries(demo8 lib8)

# 源文件
add_executable(demo9 base.cpp lib.cpp demo.cpp)

# object
add_library(base10 OBJECT base.cpp)
add_library(lib10 OBJECT $<TARGET_OBJECTS:base10> lib.cpp)
add_executable(demo10 $<TARGET_OBJECTS:lib10> $<TARGET_OBJECTS:base10> demo.cpp)
