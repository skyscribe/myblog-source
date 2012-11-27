---
layout: post
title: "Linux上如何从C++程序中获取backtrace信息"
date: 2012-11-27 21:41
comments: true
categories: linux, c++, debug, calltrace
---

许多高级程序语言都提供了出错时候的调用栈打印功能，以方便尽快得到基本的出错信息，比如Java的runtime异常栈打印和Python的pdb库都提供了详细到行号的运行时信息以便调试。作为接近系统底层的高级语言，C/C++中要达到类似的功能却是很麻烦的，因为程序中的符号信息可能被strip，甚至编译器在优化阶段也会内嵌部分函数实现代码；一旦出现内存错误或者其它异常，所能借助的手段只有产生错误现场，事后拿到coredump来验尸了。

GNU/Linux glibc提供了`backtrace`系列API可以方便地在运行时取得栈信息。

<!--more-->

backtrace 系列API
===========================

Linux的manpage提供了如下的API原型：

``` cpp 
#include <execinfo.h>
int backtrace(void **buffer, int size);
char **backtrace_symbols(void *const *buffer, int size);
void backtrace_symbols_fd(void *const *buffer, int size, fd);
```

- 第一个API根据用户传入的`buffer`数组（长度为`size`)将当前的调用栈返回，数组中每一个元素为一个函数调用地址，如果数组长度小于当前的栈帧数，那么只返回最近的调用 
- 第二个API接受第一个函数返回的buffer和size，将每一个函数地址通过符号表进行翻译，生成一个包含函数名，内部指令偏移和实际返回地址的字符串，并返回一个malloc出来的字符串数组，用户需要手工释放数组本身，但是数组的每一个指针本身则不必被用户释放 
- 在某些特殊的情况下，用户可能不能安全的申请内存（比如在signal处理函数中进行malloc就是不安全的），这时可以用第三个API，传入一个打开的fd，这样每一个栈帧都被写入到给定的fd中   


打印coredump时候的栈
======================
当程序执行到非法指令的时候或者访问非法内存的时候（更完整的情况可参考`man -s 7 signal`)，系统会产生一个对应的signal，而某些signal的默认操作就是产生一个coredump；出于诊断的目地我们也可以为这些signal注册一个处理函数，在这个处理函数中打印出当前的函数调用栈帧以便快速诊断和定位；同时人就抛出原来的signal，以方便后期调查问题根源。

例如下边的程序：

{% gist 4154534 test_bt.cpp %}

程序的输出如下：

```bash
Signal caught:11
===[1]:./bld/test_bt(_Z10handleCorei+0x41) [0x8048a2e]
===[2]:[0xaf0400]
===[3]:./bld/test_bt(_Z7faultOpv+0x10) [0x80489a4]
===[4]:./bld/test_bt(_Z7outFunci+0x1f) [0x80489eb]
===[5]:./bld/test_bt(_Z7outFunci+0x1a) [0x80489e6]
===[6]:./bld/test_bt(_Z7outFunci+0x1a) [0x80489e6]
===[7]:./bld/test_bt(_Z7outFunci+0x1a) [0x80489e6]
===[8]:./bld/test_bt(_Z7outFunci+0x1a) [0x80489e6]
===[9]:./bld/test_bt(main+0x6b) [0x8048b1a]
===[10]:/lib/i386-linux-gnu/libc.so.6(__libc_start_main+0xf3) [0x2b34d3]
===[11]:./bld/test_bt() [0x8048901]
Segmentation fault (core dumped)
```
这里通过`sigaction`注册针对非法内存访问Signal的处理，并通过设置**sa_flag**的once标志位，确保下一次的singal处理产生真正的coredump；这样我们既获取了backtrace的打印，同时又产生了调试用的coredump信息。


多线程的backtrace
===============================
多线程环境下，Linux平台上的应用程序一般都是用pthread库来支持多线程逻辑；对于较新的NPTL实现(2.6.x, glibc 2.3.2+)，pthread库符合完整的标准规定行为，每一个thread都有自己的backtrace,对应的signal在signal被触发的时候，对应的backtrace拿到的是自己线程的调用栈帧。

如下边的例子：


mangling
==================================



Google coredump library
===================================
如果要在程序的运行期产生一个coredump但不影响程序的正常执行，一般的做法是通过`gcore`工具在shell中即时产生一个core文件；这种方法的不足是，产生core的时刻预知程序运行到那一个点；如果我们想在某个运行路径处产生一个coredump，这种方法则无能为力。Google开源了一个coredump库，使得应用程序可以再给定的点上产生一个coredump而不必退出程序的运行。

链接在[google code](http://code.google.com/p/google-coredumper/), 用法如下：

``` cpp
#include <google/coredumper.h>
...
WriteCoreDump('core.myprogram');
/* Keep going, we generated a core file,
 * but we didn't crash.
  */
```


