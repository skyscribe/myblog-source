---
layout: post
title: "CMake的一些小经验"
date: 2009-12-14 14:11
comments: true
categories: [tips, cmake, build]
tags: [cmake, build]
---

初用CMake或者对其了解不太深的人，可能经常会被路径包含、库搜索路径、链接路径、RPath这些问题所绊倒，因为这些东西在手工执行gcc或者编写makefile的时候是很轻而易举的任务，但是由于CMake做了一些抽象，没有一些基本概念之前，大部分人可能会感觉有不少疑惑。其实我当初也有不少问号并像尽力往GNU Make的模式上去套，不过通过较长时间的实践和阅读manual，总算有了个相对很清晰的认识。

<!--more-->

## 如何使用其manual

cmake的帮助组织的还是很有规律的，了解了其规律，找自己想要的东西就会很简单，所以个人觉得这一点可能是最重要的。其help系统大概是这么几类：

- command
这个是实用过程中最长用到的，相当于一般脚步语言中的基本语法，包括定义变量，foreach，string，if，builtin command都在这里。大部分的CMake语句是由这些command组成的。

可以用如下这些命令获取帮助：

``` bash
cmake --help-commands
```

这个命令将给出所有cmake内置的命令的详细帮助，一般不知道自己要找什么或者想随机翻翻得时候，可以用这个。我一般更常用的方法是将其重定向到less里边，然后在里边搜索关键字。

另外也可以用如下的办法层层缩小搜索范围：

``` bash
cmake --help-command-list
cmake --help-command-list | grep find
skyscribe@skyscribe:~/program/bld$ cmake --help-command-list | grep find
find_file
find_library
find_package
find_path
find_program
```

这里找到了一些find相关的命令，可以具体查看某一个命令的manual了。


``` bash
cmake version 2.8.5
    find_library
        Find a library.

            find_library(<VAR> name1 [path1 path2 ...])

    This is the short-hand signature for the command that is sufficient in
    many cases.  It is the same as find_library(<VAR> name1 [PATHS path1
    path2 ...])

    find_library(
            <VAR>
            name | NAMES name1 [name2 ...]
            [HINTS path1 [path2 ... ENV var]]
            [PATHS path1 [path2 ... ENV var]]
            [PATH_SUFFIXES suffix1 [suffix2 ...]]
            [DOC "cache documentation string"]
            [NO_DEFAULT_PATH]
            [NO_CMAKE_ENVIRONMENT_PATH]
            [NO_CMAKE_PATH]
            [NO_SYSTEM_ENVIRONMENT_PATH]
            [NO_CMAKE_SYSTEM_PATH]
            [CMAKE_FIND_ROOT_PATH_BOTH |
            ONLY_CMAKE_FIND_ROOT_PATH |
            NO_CMAKE_FIND_ROOT_PATH]
            )

    This command is used to find a library.  A cache entry named by <VAR>
    is created to store the result of this command.  If the library is
    found the result is stored in the variable and the search will not be
    repeated unless the variable is cleared.  If nothing is found, the
    result will be <VAR>-NOTFOUND, and the search will be attempted again
    the next time find_library is invoked with the same variable.  The
    name of the library that is searched for is specified by the names
    listed after the NAMES argument.  Additional search locations can be
    specified after the PATHS argument.  If ENV var is found in the HINTS
    or PATHS section the environment variable var will be read and
    converted from a system environment variable to a cmake style list of
    paths.  For example ENV PATH would be a way to list the system path
    variable.  The argument after DOC will be used for the documentation

    ......
```

- variable

和command的帮助比较类似，只不过这里可以查找cmake自己定义了那些变量你可以直接使用，譬如OSName，是否是Windows，Unix等。
我最常用的一个例子：

``` bash
cmake --help-variable-list  | grep CMAKE | grep HOST

CMAKE_HOST_APPLE
CMAKE_HOST_SYSTEM
CMAKE_HOST_SYSTEM_NAME
CMAKE_HOST_SYSTEM_PROCESSOR
CMAKE_HOST_SYSTEM_VERSION
CMAKE_HOST_UNIX
CMAKE_HOST_WIN32
```

这里查找所有CMake自己定义的builtin变量；一般和系统平台相关。

如果希望将所有生成的可执行文件、库放在同一的目录下，可以如此做：

``` cmake
# Targets directory

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${target_dir}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${target_dir}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${target_dir}/bin)
```


这里的target_dir是一个实现设置好的绝对路径。（CMake里边**绝对路径比相对路径更少出问题**，如果可能尽量用绝对路径）

- property

Property一般很少需要直接改动，除非你想修改一些默认的行为，譬如修改生成的动态库文件的soname等。

譬如需要在同一个目录下既生成动态库，也生成静态库，那么默认的情况下，cmake根据你提供的target名字自动生成类似的libtarget.so, libtarget.a，但是同一个project只能同时有一个，因为**target必须唯一**。

这时候，就可以通过修改taget对应的文件名，从而达到既生成动态库也产生静态库的目的。譬如:


``` bash
make --help-property-list | grep NAME

GENERATOR_FILE_NAME
IMPORTED_SONAME
IMPORTED_SONAME_<CONFIG>
INSTALL_NAME_DIR
OUTPUT_NAME
VS_SCC_PROJECTNAME

skyscribe@skyscribe:~$ cmake --help-property OUTPUT_NAME
cmake version 2.8.5
    OUTPUT_NAME
        Output name for target files.

        This sets the base name for output files created for an executable or
        library target.  If not set, the logical target name is used by
        default.

```

- module

用于查找常用的模块，譬如boost，bzip2, python等。通过简单的include命令包含预定义的模块，就可以得到一些模块执行后定义好的变量，非常方便。

譬如常用的boost库，可以通过如下方式：

``` cmake
# Find boost 1.40
INCLUDE(FindBoost)
find_package(Boost 1.40.0 COMPONENTS thread unit_test_framework)
if(NOT Boost_FOUND)
    message(STATUS "BOOST not found, test will not succeed!")
endif()
```

一般开头部分的解释都相当有用，可满足80%需求,这里是_FindBoost_的文档：
``` cmake
cmake version 2.8.5
    FindBoost
        Try to find Boost include dirs and libraries

        Usage of this module as follows:

        NOTE: Take note of the Boost_ADDITIONAL_VERSIONS variable below.  Due
        to Boost naming conventions and limitations in CMake this find module
        is NOT future safe with respect to Boost version numbers, and may
        break.

        == Using Header-Only libraries from within Boost: ==

            find_package( Boost 1.36.0 )
            if(Boost_FOUND)
                include_directories(${Boost_INCLUDE_DIRS})
            add_executable(foo foo.cc)
            endif()





        == Using actual libraries from within Boost: ==

            set(Boost_USE_STATIC_LIBS        ON)
            set(Boost_USE_MULTITHREADED      ON)
            set(Boost_USE_STATIC_RUNTIME    OFF)
            find_package( Boost 1.36.0 COMPONENTS date_time filesystem system ... )


            if(Boost_FOUND)
                include_directories(${Boost_INCLUDE_DIRS})
                add_executable(foo foo.cc)
                target_link_libraries(foo ${Boost_LIBRARIES})
            endif()

```

## 如何根据其生成的中间文件查看一些关键信息
CMake相比较于autotools的一个优势就在于其生成的中间文件组织的很有序，并且清晰易懂，不像autotools会生成天书一样的庞然大物（10000+的不鲜见）。

一般CMake对应的Makefile都是有层级结构的，并且会根据你的CMakeLists.txt间的相对结构在binary directory里边生成相应的目录结构。

譬如对于某一个target，一般binary tree下可以找到一个文件夹:  __CMakeFiles/<targentName>.dir/__,比如：

``` bash
ls -l
total 84
-rw-r--r-- 1 skyscribe skyscribe 52533 2009-12-12 12:20 build.make
-rw-r--r-- 1 skyscribe skyscribe  1190 2009-12-12 12:20 cmake_clean.cmake
-rw-r--r-- 1 skyscribe skyscribe  4519 2009-12-12 12:20 DependInfo.cmake
-rw-r--r-- 1 skyscribe skyscribe    94 2009-12-12 12:20 depend.make
-rw-r--r-- 1 skyscribe skyscribe   573 2009-12-12 12:20 flags.make
-rw-r--r-- 1 skyscribe skyscribe  1310 2009-12-12 12:20 link.txt
-rw-r--r-- 1 skyscribe skyscribe   406 2009-12-12 12:20 progress.make
drwxr-xr-x 2 skyscribe skyscribe  4096 2009-12-12 12:20 src
```
这里，每一个文件都是个很短小的文本文件，内容相当清晰明了。build.make一般包含中间生成文件的依赖规则，DependInfo.cmake一般包含源代码文件自身的依赖规则。

比较重要的是flags.make和link.txt，前者一般包含了类似于GCC的-I的相关信息，如搜索路径，宏定义等；后者则包含了最终生成target时候的linkage信息，库搜索路径等。

这些信息在出现问题的时候是个很好的辅助调试手段。

## 文件查找、路径相关

- include  
    一般常用的是：  
    1. `include_directories（）` 用于添加头文件的包含搜索路径   
    2. `link_directories()` 用于添加查找库文件的搜索路径

- library search
    一般外部库的link方式可以通过两种方法来做，一种是显示添加路径，采用`link_directories()`， 一种是通过`find_library()`去查找对应的库的绝对路径。后一种方法是更好的，因为它可以减少不少潜在的冲突。

    一般find_library会根据一些默认规则来搜索文件，如果找到，将会set传入的第一个变量参数、否则，对应的参数不被定义，并且有一个xxx-NOTFOUND被定义；可以通过这种方式来调试库搜索是否成功。

    对于库文件的名字而言，动态库搜索的时候会自动搜索libxxx.so (xxx.dll),静态库则是libxxx.a（xxx.lib），对于动态库和静态库混用的情况，可能会出现一些混乱，需要格外小心；一般尽量做匹配连接。

- rpath
所谓的rpath是和动态库的加载运行相关的。我一般采用如下的方式取代默认添加的rpath：

``` cmake
SET(CMAKE_SKIP_BUILD_RPATH  FALSE)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) 
SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE) 
```

## 参考
CMake Home: [link](http://www.cmake.org/)
