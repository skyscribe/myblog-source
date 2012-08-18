---
layout: post
title: "VIM下实现对C++ STL的IntelliSense"
date: 2010-01-10 18:28
comments: true
categories: [cpp, tips, vim]
---

以前尝试过在vim下配置STL的Intellisense曾经没有成功；最近有空刚好仔细看了下vim的一些相对高级的manual，总算将[OmniCppComplete](http://www.vim.org/scripts/script.php?script_id=1520)主页上的效果给弄了出来（[这里](http://vissale.neang.free.fr/Vim/OmniCppComplete/ScreenShots/screenshots.htm)）。

具体步骤基本是按照其help按部就班，具体可在安装完OmniCppComplete之后，用`:help cppcomplete`查看。

## 首先需要有ctags, 并且必须是Exuberant ctags

默认的Unix环境里边安装的ctags很肯能不是这个版本，不过Linux机器大部分都有。我的Ubuntu上已经是最新版了:

<!--more-->

```bash
skyscribe@skyscribe-ubuntu:~$ ctags --version
Exuberant Ctags 5.9~svn20110310, Copyright (C) 1996-2009 Darren Hiebert
    Compiled: Jul 27 2011, 11:05:43
    Addresses: <dhiebert@users.sourceforge.net>, http://ctags.sourceforge.net
    Optional compiled features: +wildcards, +regex
```

## 加入autoload

在 ~/.vimrc 里边加入autoload taglist功能，为了方便自动更新当前tags，设置一个快捷键（这里）：
``` vim
map <C-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
source ~/.vim/my.vim
```

这里的自动加载已有vim的功能，就用一个vim脚步来实现 (参考 vim :help glob给的例子)：

``` vim
cat ~/.vim/my.vim 
let tagfiles = glob("`find ~/.vim/tagfiles -name tags -print`")
let &tags = substitute(tagfiles, "\n", ",", "g")
```

以后需要新的taglist，只需要放在~/.vim/tagfiles目录下就好了。
vim启动的时候，会自动执行~/.vimrc，从而调用my.vim，将事先准备好的taglist更新进去；这里一般放一些不太变化的静态头文件tag就可以了。

## 生成STL tags

要有STL的intelliSense，自然要有STL C++的tags database了，这里需要生成之。
根据上一步的惯例，需要生成一个tags文件，放在~/.vim/tagfiles/的某个子目录下：

``` bash
mkdir -p ~/.vim/tagfiles/gcc<ver>/
ls –l /usr/include/c++/
```
这里需要将ver换成当前系统的libstdc++版本，Ubuntu 9.10上的是4.4.1.

用上边的命令生成taglist：
``` bash
ctags -R --c++-kinds=+p --fields=+iaS --extra=+q . -o ~/.vim/tagfiles/gcc4.4/tags /usr/include/c++/4.4
```

## 可能的问题

写一个简单的c++程序，在Insert Mode下，Ctrl+X， Ctrl+P，发现并不能工作，什么提示也没有；初步怀疑是对应的tag文件不对。

幸好早有人尝试过了，给出了一种办法([这里](http://design.liberta.co.za/articles/code-completion-intellisense-for-cpp-in-vim-with-omnicppcomplete/)），可惜他的方法我试了不行，不过已经可以借用他的思路了：

1. 将/usr/include/c++/4.4.1/的内容全部拷贝到一个目录下：
``` bash
mkdir gcc4.4
cp -R /usr/include/c++/4.4 ./
```

2. 写一个脚步替换所有的NAMESPACE宏定义(这里用sed完成宏替换，为了避免过于晦涩，还是放在一个临时的脚步文件里边来，便于调试吧)：

{% gist 1964161 %}

3. 生成tags
``` bash
skyscribe@skyscribe:~/libstdc++/gcc4.4$ ./generate-tags.sh . 
==================================================================================================== 100
==================================================================================================== 200
==================================================================================================== 300
==================================================================================================== 400
==================================================================================================== 500
==================================================================================================== 600
===============================================================Processed 663 files!

generated tag file!
ls tags -lh
-rw-r--r-- 1 skyscribe skyscribe 4.2M 2010-01-10 18:21 tags
cp tags ~/.vim/tagfiles/gcc4.4/
```

## 实验效果

到这里效果终于出来了:

上边的review窗口显示当前调用的函数信息,输入./->/:: 的时候会自动提示，也可以用CTRL+X CTRL+O 来调出提示窗口。

![vim intellisense1][1]
![vim intellisense2][2]

方向键则可以选择。
![vim intellisense3][3]


[1]: /images/vim-stl-1.png "vim complete 1"
[2]: /images/vim-stl-2.png "vim complete 2"
[3]: /images/vim-stl-3.png "vim complete 3"
