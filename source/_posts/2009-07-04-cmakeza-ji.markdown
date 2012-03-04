---
layout: post
title: "cmake杂记"
date: 2009-07-04 13:15
comments: true
categories: [cmake, tips, build]
---

CMake常用技巧：

<!--more-->

- 尽量使用外部build而不是内部build.
所谓的内外，指的是make目录和CMakeLists.txt不在一个目录下。
好处是，所有的临时文件都会生成在当前运行cmake/make的目录。
譬如在项目根目录有一个CMakeLists.txt作为top-level file, 几个代码子目录，一个build目录，可以用：

``` cmake
cd build
cmake ..
make
```
此时中间文件不会污染项目的目录结构。

- 动态库和静态库

可以用如下方式生成同名的静态库和动态库
```cmake
set(libname "mylib")

add_library(libname_static STATIC src1 src2)
set_target_properties(libname_static OUTPUT_NAME ${libname})

add_library(libname SHARED src1 src2)
```

- 获取当前运行目录

可以在根目录设置一个project_dir变量，设置为源代码目录，如下
``` cmake
set(project_top_dir ${CMAKE_CURRENT_SOURCE_DIR}/")

add_subdirectory(sub1)
add_subdirectory(sub2)
```
此时，各个子目录中可以应用project_top_dir.

- 处理跨平台的第三方库

假设第三方库不是由CMake编译得来，但要检测依赖和变动，则可以用imported属性：

``` cmake
add_library(ssllib SHARED IMPORTED)
add_library(cryptolib SHARED IMPORTED)
#May have different dependent libraries
set(libsuffix ${CMAKE_SYSTEM_NAME}_${CMAKE_SYSTEM_PROCESSOR})
set_target_properties(ssllib PROPERTIES IMPORTED_LOCATION "${project_top_dir}contrib/openssl/lib/libssl-${libsuffix}.so")
set_target_properties(cryptolib PROPERTIES IMPORTED_LOCATION "${project_top_dir}contrib/openssl/lib/libcrypto-${libsuffix}.so")
//........................
#other CMakeLists.txt
add_executable(myExe src1 src2)
target_link_libraries(myExe ssllib cryptolib)
```
