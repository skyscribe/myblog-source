---
layout: post
title: "Boost.CMake-解决boost升级问题"
date: 2010-05-09 21:56
comments: true
categories: [cpp, boost, tips]
tags: [cpp, boost]
---


以前常用boost的一些库，由于项目自身用[CMake](http://www.cmake.org/)组织build,跟着最新版本升级是很自然的想法。问题是，boost每次升级之后，重新用bjam编译一次都很是不便（某些平台，用默认选项编译有些问题，有时候往往安装不成功）。

最近才发现boost的cmake版本已经独立出来了，对于使用cmake的用户而言，这里是个不错的选择。[项目主页](https://svn.boost.org/trac/boost/wiki/CMake)的文档很是清晰，最新的版本是1.41 (版本号对应的基本就是其upstream的boost版本号)。源代码是用git组织的，对于Linux用户而言更加方便。

<!--more-->

引用其主页上的一句话：
> Boost.CMake (or alt.boost ) is the boost distribution that all the cool kids are using. 

CMake + GIT +Spinx 确实够酷了。

编译起来可以充分利用强大的CMake了：
``` bash
git clone git://gitorious.org/boost/cmake.git src
cd src
git checkout <TAG>    //TAG==1.41.0.cmake0
mkdir bld
cd bld/
cmake ../
```

如果需要按需编译某些库，只需用`make edit_cache`修改cache即可。
