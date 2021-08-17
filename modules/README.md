# 存在 protoc, include directories 跟 libraries 的情况

```
set (Protobuf_INCLUDE_DIRECTORIES "path/to/include_directories")
set (Protobuf_LINK_LIBRARIES "path/to/link_librarires")
set (Protobuf_PROTOC_PATH "path/to/protoc")
find_package (Protobuf)
```

# 从网络下载 protobuf，并编译

```
set (Protobuf_DOWNLOAD_URL https://github.com/protocolbuffers/protobuf/archive/refs/tags/v3.17.3.tar.gz)
find_package (Protobuf)
```

一旦操作成功，会导出下面几个变量

- Protobuf_INCLUDE_DIRECTORIES
- Protobuf_LINK_LIBRARIES
- Protobuf_PROTOC_PATH
