if (Protobuf_DOWNLOAD_URL)
    include (FetchContent)

    FetchContent_Declare (protobuf
        URL ${Protobuf_DOWNLOAD_URL}
    )
    FetchContent_GetProperties(protobuf)
    if (NOT protobuf_POPULATED)
        FetchContent_Populate(protobuf)
        set (protobuf_BUILD_TESTS OFF CACHE BOOL "" FORCE)
        add_compile_options ("-fPIC")
        add_subdirectory (${protobuf_SOURCE_DIR}/cmake
            ${protobuf_BINARY_DIR}
            EXCLUDE_FROM_ALL
        )
    endif ()

    # 导出 Protobuf_INCLUDE_DIRECTORIES, Protobuf_LINK_LIBRARIES, Protobuf_PROTOC_PATH 三个变量
    set (Protobuf_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:libprotobuf,INCLUDE_DIRECTORIES>)
    set (Protobuf_LINK_LIBRARIES libprotobuf)
    set (Protobuf_PROTOC_PATH $<TARGET_FILE:protoc>)
    set (Protobuf_SOURCE_DIR ${protobuf_SOURCE_DIR})
elseif (NOT DEFINED Protobuf_INCLUDE_DIRECTORIES 
        OR NOT DEFINED Protobuf_LINK_LIBRARIES 
        OR NOT DEFINED Protobuf_PROTOC_PATH
    )
    message (FATAL_ERROR "must config Protobuf_INCLUDE_DIRECTORIES, Protobuf_LINK_LIBRARIES, Protobuf_PROTOC_PATH")
endif ()

# 为一组 proto 文件生成一个 target
# example:
#   add_proto_library (test_protos_lib OBJECT
#       GENERATED_CPP_DIR ${CMAKE_CURRENT_BINARY}/proto-gen-cpp
#       PROTO_ROOT_DIRECTORY ${CURRENT_SOURCE_DIR}
#       PROTO_LIST src/test.proto
#       PROTO_DIRECTORIES ${CURRENT_SOURCE_DIR}
#   )
function (add_proto_library target)
    set (options
        STATIC # 编译成静态库
        OBJECT  # 编译成 object, 这是默认参数
        SHARED  # 编译成共享库
        MODULE  # 供 dlopen 加载的动态库
        VERBOSE # 显示 log
    )
    set (one_value_keywords
        PROTO_ROOT_DIRECTORY # 用以确定生成的 cpp 文件结构的根目录
        GENERATED_CPP_DIR    # 生成路径, 如果没有设置此参数, 默认为 ${CMAKE_CURRENT_BINARY_DIR}/proto-gen-cpp
    )
    set (multi_value_keywords
        PROTO_DIRECTORIES       # proto 文件夹，文件夹下的所有文件都会加入到生成列表中
        PROTO_LIST              # proto 文件列表
        IMPORT_DIRECTORIES      # 编译 proto 时的搜索路径
        LINK_LIBRARIES          # 需要链接的 library，如果设置了 OBJECT，这个参数将会被忽略
    )
    cmake_parse_arguments (p
        "${options}"
        "${one_value_keywords}"
        "${multi_value_keywords}"
        ${ARGN}
    )

    # 处理 GENERATED_CPP_DIR
    if (NOT p_GENERATED_CPP_DIR)
        set (p_GENERATED_CPP_DIR ${CMAKE_CURRENT_BINARY_DIR}/proto-gen-cpp)
    endif ()

    # 将 PROTO_DIRECTORIES 下的 proto 文件加到 relative_proto_list 中
    foreach (proto_directory ${p_PROTO_DIRECTORIES})
        file (GLOB temp_proto_list RELATIVE ${p_PROTO_ROOT_DIRECTORY} "${proto_directory}/*.proto")
        list (APPEND relative_proto_list ${temp_proto_list})
    endforeach ()

    # 将 PROTO_LIST 中的 proto 文件添加到 relative_proto_list 中
    foreach (proto_file ${p_PROTO_LIST})
        # 如果使用的是相对路径，将其转换为绝对路径
        string (REGEX MATCH "^/.*$" matched ${proto_file})
        if ("${matched}" STREQUAL "")
            set (proto_file ${CMAKE_CURRENT_SOURCE_DIR}/${proto_file})
            message (STATUS "relative path: ${proto_file}")
        endif ()

        file (RELATIVE_PATH relative_proto ${p_PROTO_ROOT_DIRECTORY} ${proto_file})
        list (APPEND relative_proto_list ${relative_proto})
    endforeach ()

    # 显示输入的 proto 文件列表
    if (p_VERBOSE)
        message (STATUS "proto list: ${relative_proto_list}")
    endif ()

    # 设置 protoc 的 include directories
    # PROTO_ROOT_DIRECTORY 将会被自动加到 include directories 中
    set (proto_path_list "--proto_path=${p_PROTO_ROOT_DIRECTORY}")
    foreach (item ${p_IMPORT_DIRECTORIES})
        list (APPEND proto_path_list "--proto_path=${item}")
    endforeach ()

    message (STATUS "proto path list: ${proto_path_list}")

    # 调用 protoc 生成 cpp 文件
    foreach (proto_file ${relative_proto_list})
        get_filename_component (_directory ${proto_file} DIRECTORY)
        get_filename_component (_filename ${proto_file} NAME_WLE)
        set (generated_cpp_src "${p_GENERATED_CPP_DIR}/${_directory}/${_filename}.pb.cc")
        set (generated_cpp_hdr "${p_GENERATED_CPP_DIR}/${_directory}/${_filename}.pb.h")

        set (_proto ${p_PROTO_ROOT_DIRECTORY}/${proto_file})
        add_custom_command (OUTPUT ${generated_cpp_src} ${generated_cpp_hdr}
            DEPENDS ${Protobuf_PROTOC_PATH} ${_proto}
            COMMENT "generate: ${generated_cpp_hdr} ${generated_cpp_src}, proto: ${_proto}"
            COMMAND ${CMAKE_COMMAND} -E make_directory ${p_GENERATED_CPP_DIR}/${_directory}
            COMMAND ${Protobuf_PROTOC_PATH} ${proto_path_list} --cpp_out=${p_GENERATED_CPP_DIR} ${_proto}
            VERBATIM
        )
        list (APPEND generated_cpp_list ${generated_cpp_src} ${generated_cpp_hdr})
    endforeach ()

    # 获取 target 类型
    set (target_type OBJECT)
    if (p_STATIC)
        set (target_type STATIC) # 默认 STATIC
    elseif (P_OBJECT)
        set (target_type OBJECT)
    elseif (p_SHARED)
        set(target_type SHARED)
    elseif (P_MODULE)
        set (target_type MODULE)
    endif ()

    # 设置 include_directories
    add_library (${target} ${target_type} ${generated_cpp_list})
    target_include_directories (${target} PUBLIC
        ${p_GENERATED_CPP_DIR}
        ${Protobuf_INCLUDE_DIRECTORIES}
    )

    # 根据需要链接 libprotobuf
    if (NOT "${target_type}" STREQUAL "OBJECT")
        target_link_libraries (${target} ${p_LINK_LIBRARIES})
    endif ()
endfunction ()