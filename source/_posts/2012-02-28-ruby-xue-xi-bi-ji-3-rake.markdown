---
layout: post
title: "Ruby学习笔记-3 Rake"
date: 2012-02-28 20:19
comments: true
categories: [study, build, rake, ruby, 学习笔记]
tags: [study, ruby]
---

## Rake - the make in ruby world

### 简介

**Rake** 是一个简单的用于构建ruby程序的工具，其作用类似于C/C++中的[Make](http://www.gnu.org/software/make/)工具，不过其本身采用ruby的语法，并且自带一些模块用于快速创建一些通用的make任务。其主要功能如下：[link](http://rake.rubyforge.org/) 

- 使用ruby自身语法描述，没有烦人的XML，更不用担心make中诡异的TAB/SPACE问题
- 支持模式规则以方便合成隐式任务
- 可以为task指定前提条件
- 灵活的Filelist - 行为类似Array,但是易于操作文件名和路径
- 预打包的任务库，方便生成Rakefile

<!--more-->

### 安装
采用gem来安装是最方便不过了，一条命令即可：

{% codeblock lang:bash %}
gem install --remote rake
{% endcodeblock %}


### Rake规则

#### Dependency

采用hash描述，例如 

{% codeblock lang:ruby %}
file "main.o" => ["main.c", "test.c"]
file "test.o" => ["test.c"]
file "progrm" => ["main.o", "test.o"]
{% endcodeblock %}

这里的三条规则指定了常见的一个测试程序的文件依赖关系，对应的make规则如下(这里省略了build规则，实际make中可能需要指定)：

{% codeblock lang:bash %}
main.o : main.c test.c
test.o : test.c
porgrm : main.o test.o
{% endcodeblock %}

#### build

和Make比较类似，只需要在dependency之后加上一个do/end块，描述实际动作就可。例如：

{% codeblock lang:ruby %}
file "main.o" => ["main.c", "test.c"] do
    sh "cc -c -o main.o main.c"
end
file "test.o" => ["test.c"] do
    sh "cc -c -o test.o test.c"
end
file "progrm" => ["main.o", "test.o"] do
    sh "cc -o progrm main.o test.o"
end
{% endcodeblock %}

实际执行build任务的时候，只要执行`rake program`即可。

### 一些通用规则

- 默认生成对象

在Make中，第一个规则对应的目标对象为默认的生成对象（即不指定参数时的生成对象）；rake指定默认目标的方法如下：

{% codeblock lang:ruby %}
task :default => ["program"]
{% endcodeblock %}

这里指定了默认生成program.

- task种类

分为file task和non-file task，用file指定的task，其文件时间戳会被自动记录和比较以决定是否重新build。task指定的对象不会检查和创建文件，也不会检查和比较时间戳。

- clean和cobber

这是两个常用的目标，clean用于清理中间产生的临时文件，cobber则用于清理build中间产生的所有文件。这两个目标如此常用以至于rake本身就预定义了它们，用户只需要通过Filelist来指定即可。

- Filelist

一个Filelist用于列出一堆的文件，rake允许灵活的语法来指定filelist，比如：
    
{% codeblock lang:ruby %}
SRC = Filelist['*.cpp']
{% endcodeblock %}

这里的SRC包含了所有的.cpp为后缀的文件。

Filelist具有如下特征：
- 支持glob，如.\*等统配符
- 文件查找总是在Rakefile本身所在的目录进行

### Dynamic feature

通过灵活的ruby语法，rake可以支持动态创建规则 - ruby自身的循环等总是可以用的：

{% codeblock lang:ruby %}
SRC = FileList['*.c']
SRC.each do |fn|
  obj = fn.sub(/\.[^.]*$/, '.o')
  file obj  do
    sh "cc -c -o #{obj} #{fn}"
  end
end
{% endcodeblock %}

上边的这个例子中，对所有的".c"文件，创建了一个对应的file规则用于自动生存".o"文件。

### 参考
1. Rake tutorial [link](http://rake.rubyforge.org/)
