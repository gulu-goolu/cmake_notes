include (FetchContent)

# 为一组 proto 文件生成一个 target
# example:
#   aibox_add_proto_library (mlplat-protos OBJECT
#       GENERATED_CPP_DIR ${CMAKE_CURRENT_BINARY}/gen-cpp
#       PROTO_ROOT_DIRECTORY ${MLPLAT_DIR}/mlplat-protos
#       PROTO_DIRECTORIES ${MLPLAT_DIR}/mlplat-protos
#   )
function (aibox_add_proto_library target)
    set (options
        LIBRARY # 编译成静态库
        OBJECT  # 编译成 object
        SHARED  # 编译成共享库
        MODULE  # 供 dlopen 加载的动态库
        VERBOSE # 显示 log
    )
    set (one_value_keywords
        PROTO_ROOT_DIRECTORY # 用以确定生成的 cpp 文件结构的根目录
        GENERATED_CPP_DIR    # 生成路径
    )
    set (multi_value_keywords
        PROTO_DIRECTORIES           # proto 文件夹，文件夹下的所有文件都会加入到生成列表中
        PROTO_LIST                  # proto 文件列表
        PROTO_INCLUDE_DIRECTORIES   # 编译 proto 时的搜索路径
        LINK_LIBRARIES              # 需要链接的 library，如果设置了 OBJECT，这个参数将会被忽略
    )
    cmake_parse_arguments (p
        "${options}"
        "${one_value_keywords}"
        "${multi_value_keywords}"
        ${ARGN}
    )

    # 处理 GENERATED_CPP_DIR
    if (NOT p_GENERATED_CPP_DIR)
        set (p_GENERATED_CPP_DIR ${CMAKE_CURRENT_BINARY_DIR}/protobuf-cpp)
    endif ()

    # 将 PROTO_DIRECTORIES 下的 proto 文件加到 relative_proto_list 中
    foreach (proto_directory ${p_PROTO_DIRECTORIES})
        file (GLOB temp_proto_list RELATIVE ${p_PROTO_ROOT_DIRECTORY} "${proto_directory}/*.proto")
        list (APPEND relative_proto_list ${temp_proto_list})
    endforeach ()

    # 将 PROTO_LIST 中的 proto 文件添加到 relative_proto_list 中
    foreach (proto_file ${p_PROTO_LIST})
        file (RELATIVE_PATH temp_relative_path ${p_PROTO_ROOT_DIRECTORY} ${proto_file})
        list (APPEND relative_proto_list ${temp_relative_path})
    endforeach ()

    # 显示输入的 proto 文件列表
    if (p_VERBOSE)
        message (STATUS "proto list: ${relative_proto_list}")
    endif ()

    # 设置 protoc 的 include directories
    # PROTO_ROOT_DIRECTORY 将会被自动加到 include directories 中
    set (proto_path_list "--proto_path=${p_PROTO_ROOT_DIRECTORY}")
    foreach (item ${p_PROTO_INCLUDE_DIRECTORIES})
        list (APPEND proto_path_list "--proto_path=${item}")
    endforeach ()

    # 调用 protoc 生成 cpp 文件
    foreach (proto_file ${relative_proto_list})
        get_filename_component (_directory ${proto_file} DIRECTORY)
        get_filename_component (_filename ${proto_file} NAME_WLE)
        set (generated_cpp_src "${p_GENERATED_CPP_DIR}/${_directory}/${_filename}.pb.cc")
        set (generated_cpp_hdr "${p_GENERATED_CPP_DIR}/${_directory}/${_filename}.pb.h")

        set (_proto ${p_PROTO_ROOT_DIRECTORY}/${proto_file})
        add_custom_command (OUTPUT ${generated_cpp_src} ${generated_cpp_hdr}
            DEPENDS protoc ${_proto}
            COMMENT "generate: ${generated_cpp_hdr} ${generated_cpp_src}, proto: ${_proto}"
            COMMAND ${CMAKE_COMMAND} -E make_directory ${p_GENERATED_CPP_DIR}/${_directory}
            COMMAND protoc "${proto_path_list}" --cpp_out=${p_GENERATED_CPP_DIR} ${_proto}
        )
        list (APPEND generated_cpp_list ${generated_cpp_src} ${generated_cpp_hdr})
    endforeach ()

    # 获取 target 类型
    set (target_type OBJECT)
    if (p_LIBRARY)
        set (target_type LIBRARY)
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
        $<TARGET_PROPERTY:libprotobuf,INCLUDE_DIRECTORIES>
    )

    # 根据需要链接 libprotobuf
    if (NOT ${target} EQUAL "OBJECT")
        target_link_libraries (${target} ${p_LINK_LIBRARIES})
    endif ()
endfunction ()

