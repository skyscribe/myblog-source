---
layout: post
title: "利用CMake搭建开发build环境"
date: 2009-07-01 21:51
comments: true
categories: [cmake, build, tips, cpp]
---
对于经常在终端下写程序的non-windows程序员，Makefile绝对是最常用的工具，小到一个文件的简单的测试程序，大到数百个文件的商业软件，只需要有shell，一个make命令就可得到可运行的程序，Makefile绝对功不可没；可惜世界中不是那么太平，不但各个Posix系统的API千差万别，硬件平台各异，就连Makefile本身也有多个不兼容的格式，譬如GNU Makefile 拿到Solaris平台上就没法make下去，除非你有gmake，但gmake对并行编译的支持就没有solaris自带的dmake要好了。

GNU autotools提供了一个不错的选择，可以做到组织工具链来生成所需的Makefile，但缺陷是学习起来比较麻烦，而且模版文件写起来比较费劲。老实说我跟Makefile打了近3年的交道，几乎没有自己写过automake脚本，相反的工作倒是干了不少，譬如分析生成的Makefile运行过程，然后模拟自己手写Makefile；得到一个轻爽的定制环境。

除了autotools，其实也有不少其他的工具，譬如apache的ant，基于Python的scons；ant在java界是鼎鼎大名了，可惜对c++的支持确实让我感觉很不习惯；scons号称可以嵌入Python代码，用起来也算简单，但是想实现复杂的功能就很头疼了，而且运行速度让人挠头。

cmake则弥补了上述几个工具的诸多缺陷：
<!--more-->

1. 易于学习，文档易懂，只需牢记以下命令即可：
```bash
cmake --help
cmake --help-command-list
cmake --help-command xxx
cmake --help-variable-list
cmake --help-variable yyy
```

2. 以文本文件组织，利用cache的方式，所有的自定义cache变量可直接用vim查看。   
3. 生成的Makefile文件简洁易懂     
4. 编译器选项可自己在ccmake中编辑，利于交叉编译    
5. 支持集成ctest/cpack,前者可以方便的做单元测试，后者则可以打包生成tgz/rpm  
6. 支持多个生成器，可以生成eclipse/codeblocks/gmake/unix make文件，甚至可以生成VC各个版本的dsw/sln.  
7. 内嵌语言，可以自己写函数、宏等  

对于经常写小测试程序的人来说，在test目录下加上个CMakeLists.txt，里边加上几行简单的语句就可以方便的以后重复使用了。对于这种情况，手工写的Makefile碰到依赖检测这种麻烦的事情往往力不从心，automake又太小题大作，而cmake则恰到好处了。

对于大型程序，cmake可以自己定制生成的中间文件和目标文件路径，有效避免了automake带来的每个目录下生成一大堆文件的弊端，也不需要手工写Makefile。
最有用的是可以生成多个知名IDE的工程文件，包括Windows下的vc6-vc9.

