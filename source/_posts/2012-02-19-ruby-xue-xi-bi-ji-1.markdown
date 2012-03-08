---
layout: post
title: "ruby学习笔记-1"
date: 2012-02-19 15:58
comments: true
categories: [study, 学习笔记, ruby]
tags: [study, ruby]
---

看得再多也不如自己动手试，最近有闲就打算认真研究一下ruby语言了。[Pragmatic programmer](http://pragprog.com/the-pragmatic-programmer)中说，需要一年学一门新语言一遍改造思想，去年浅浅的学了javascript的皮毛，今年可以看看ruby这个有lisp之风的OO语言了。

## 安装环境

第一个想到的是apt-get来下载了，得到的是一个交互式解析器和编译器。和python的比较类似，不过ruby的交互程序是个单独的程序叫做irb。

        skyscribe:~$ ruby --version
        ruby 1.8.7 (2011-06-30 patchlevel 352) [i686-linux]
        skyscribe:~$ irb
        irb(main):001:0> puts "hello"
        hello
        => nil

可惜得到的不是比较新的版本。

不过很快想起翻翻 [wiki](http://en.wikipedia.org/wiki/Ruby_%28programming_language%29)，还是用[**RVM**](http://beginrescueend.com/)方便的多。教程比较简单，参考它的[quick installation guide](http://beginrescueend.com/rvm/install/)就可。第一次尝试的时候用apt-get安装了没有purge，导致总是安装到root用户造成“permission denied"的问题。

<!--more-->

安装好之后，所有的东西都在$HOME/.rvm下边，比较干脆。

        skyscribe:~$ rvm install 1.9.3
        skyscribe:~$ rvm list

        rvm rubies

        ruby-1.9.3-p125 [ i686 ]

        # Default ruby not set. Try 'rvm alias create default <ruby>'.

        # => - current
        # =* - current && default
        #  * - default

        skyscribe:~$ rvm alias create default ruby-1.9.3-p125
           Creating alias default for ruby-1.9.3-p125.
           Recording alias default for ruby-1.9.3-p125.
           Creating default links/files

自动加入shell启动脚本更方便：

        skyscribe:~$ cat >> ~/.bashrc
        [[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # This loads RVM into a shell session.
        ^C
        skyscribe:~$ bash
        skyscribe:~$ rvm use 1.9.3
        Using /home/skyscribe/.rvm/gems/ruby-1.9.3-p125

        skyscribe:~$ ruby -v
        ruby 1.9.3p125 (2012-02-16 revision 34643) [i686-linux]

## 熟悉和上手

官方的文档是最好的参考，推荐[ruby koans](http://rubykoans.com/),下载下来，解压后，是个典型的TDD学习材料，不断运行

         ruby path_to_enlightenment.rb

koans 会遍历每一个test case直到全部完毕，大概需要2个小时以上的时间方可全部完工。中间的注释和THINK ABOUT的部分比较有意思，做testcase的时候停下来仔细看看注释也大有裨益。每一个testcase本身的名字也清晰的列举了其关注的知识点，用来了解语法是最好不过了。

## 一点感悟

- 完完全全的OO，所有东西皆为对象
- 两种基本的collection，hash和array基本对应于python的dict和array
- 函数调用可以不必添加括号，除非可能引发歧义或者解析错误
- 函数参数可以包含block，支持lambda和closure
- bool类型更简单，只有false和nil与false等价，其余全部是true
- 控制结构有unless
- 类定义是开放式的，便于非侵入式设计，当然也可以允许修改builtin
- 每一个对象都有object id
- symbol和string可以互相转化构造
- method的调用可以用send 的方法发送message -  proxy变得极度容易
- module可以被class include从而包含方法， 便于mixin设计
- instance variable和class variable 定义方便快捷
- regular expresion的和python极为相似
- 变量的scope用$/@等符号来标注，也算容易记忆

