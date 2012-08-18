---
layout: post
title: "利用LD_PRELOAD发现程序潜在的问题"
date: 2009-06-30 22:05
comments: true
categories: [cpp, debugging, unix]
---

Solaris上，常常可以用**LD_PRELOAD**辅助_mdb_做一些调试、测试工作，可以发现一些其它手段难以发现的问题；最近就遇到一个。

事情源于替换了程序中的某个基础部分之后，程序运行起来占用的物理内存有了较为显著的增加，却难以一下子拿出来个让人信服的原因。于是自然想到了去看一下程序真正运行的时候，某一部分内存是谁分配的。之前用` pmap -xalsF pid`发现_heap_部分有显著增加，又不是在新加入的那个动态库里边。

Solaris上有强大的mdb，辅助不同的模块可以得出很多有意思的结论，其中libumem.so即可以查看内存的分配的情况，并可以检测是否有内存泄漏。
<!--more-->

## 启动方法

可以参看其manpage，主要是几个环境变量：
``` bash
export UMEM_DEBUG=default
export UMEM_LOGGING=transaction
LD_PRELOAD=/lib/libumem.so
export LD_PRELOAD
```

然后在此shell中启动程序，新打开一个终端，同样设置好LD_PRELOAD（否则会提示错误），查找正运行的程序的进程号（调试的程序），生成一个core文件：
``` bash
ps -ef | grep <appname>
gcore <pid>
ls core.<pid>
```

用mdb打开新生成的core文件，第一行应该提示加载了libumem.so.
接下来，用libumem.so提供的walker和dcmds就可以查询程序运行以来到产生core文件的那一时间点丰富的内存信息了.

``` bash
mdb core.pid
>::findleaks
>::umalog
>::umem_log
```

更多可用的命令，可以用`::dmods -l`查看。

整个过程非常繁杂，因为应用程序比较大，分配内存的log实在是太多了，但是突然发现运行目录下边多了不少core文件，一下子奇怪了，之前可是花费了很多时间在提高代码质量上，按道理不应该会有core产生了。打开这些core，用pstack，居然发现某个模块启动的子进程在调用free的地方abort了，按图索骥查看代码，在某个旮旯里边，几年没人动的小角落里，发现分配内存的地方：

``` c
char* path1 = getenv("MYENV");
char path2[] = "bin/logDir/log.xxx"
char* path = malloc(sizeof(path1) + sizeof(path2));
strcpy(path, path1);
strcat(path, path2);

//more code ...

free(path);
exit(0);

.
```
原来最初写这块纯C代码的人打了马虎眼，分配的内存有问题，导致free的时候出问题，但正常情况下，这里的exit之后，进程也就退出了，居然没有core文件出来，导致这个Bug居然被隐藏了数年。

libumem和LD_PRELOAD居然把它挖了出来，马上修改之。

## 教训

所谓“祸患常积于忽微”，最不起眼的地方，往往会衍生一些麻烦，不时咬你一口。
讨厌的"legacy code without evolution/refactoring/test......"，每个负责任的职业程序员都应该去深思

- Linux上似乎也有libumem.so，但是却没有pstack/mdb这些好用的工具，只有valgrind/gdb了；solaris上不但有mdb/dtrace,还有dbx,虽然gdb也是可用的
- valgrind 其实也是个很优秀的工具，不过没有MDB强大了
