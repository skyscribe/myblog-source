---
layout: post
title: "UNIX神器之awk/gawk"
date: 2011-01-02 20:32
comments: true
categories: [awk, tips, tools]
tags: [awk, programming, gawk, UNIX]
---

## AWK及特点

日常在shell中使用awk基本是家常便饭了，但是详细的写一些小程序还是第一次，总体是下来，还是深深得被这门年龄比自己都要大的工具语言的魅力所折服（[since 1977](http://groups.engin.umd.umich.edu/CIS/course.des/cis400/awk/awk.html#history)）。作者中最引人注目的当属鼎鼎大名的[Brian W. Kernighan](https://secure.wikimedia.org/wikipedia/en/wiki/Brian_Kernighan) (即K的简称来源）。目前所用的版本大多是gawk或者nawk.

作为一门微型且完整的编程语言，awk可以用数行代码就完成其他语言需要数倍的LOC才能完成的工作。其设计哲学也是比较特殊的，核心是data－driven的，并且采用了和C类似的语法来组织。它最核心的思想应该是如下两点：

- pattern-action 结构 借由强大的正则表达式来匹配pattern，然后执行pattern对应的操作   
- Record/Field 处理模型  所有的输入数据都根据制定的record separator 分割成 record  
    - 每一个record再根据field separator 分割为fields. POSIX 定义的 field separator可以为正则表达式，而gawk可以允许record separator同时为正则表达式    
    - 采用预定义变量来获取field

<!--more-->

## 缘起

引发我花点时间来仔细研究awk的起因是这样的，我们的程序在做profiling的时候，发现原来用shell写的脚本分析一次话费的时间太长。初看了下那个脚本，大概的逻辑是要扫名所有的log文件，按照时间戳将关注的时间所耗费的时间提取出来，计算平均值，波动等最终画出曲线图。

整体的脚本有几个部分（python＋bash），处理一次40MB的log文件需要耗费40分钟～1个小时，这显然超出了预期；中间一个处理很长的部分是grep某个时间段的信息然后按照报表格式写入到中间文件中。在想能否优化这一节的时候，忽然就想起了模式匹配来（学习Haskell的最深印象），于是大致翻了一下awk，发现很容易通过模式匹配使得按行处理，同时记录中间的信息，而一个时间段恰好和awk的record概念吻合。

花了2个小时研读了下awk的函数语法，自定义自己的时间截取函数（gawk的strftime很有用，尤其我们发现记录有跳跃要自动补全中间的数据记录时），通过三个pattern截取需要的信息，30分钟写出来awk的代码来。

所幸的是，其它的shell脚本都不需要任何改动，重新跑一次，3s就处理完了原来40MB的文件，看来这点时间投入还是相当值得的。

## 其它

- 有兴趣的可参考[GNU的文档](http://www.gnu.org/manual/gawk/gawk.html)
- awk的另一作者[Winberger](https://secure.wikimedia.org/wikipedia/en/wiki/Peter_J._Weinberger)供职于google。 

