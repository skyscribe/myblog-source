---
layout: post
title: "Github pages upgrade"
date: 2013-08-04 23:07
comments: true
categories: github
---

GitHub的后台发生了更新，原来的**github.com**换成了**github.io**，导致原来的**octopress**的Rakefile变得不能正常工作。
<!--more-->

## Octopress升级的问题

只需要按照常规的步骤，用git更新其upstream即可。问题在于更新之后，scss可能不工作了，导致打开后看到的主页显示不正常。

Google之，解决方法如下：
```bash
rake update_style
rake clean
rake generate
rake deploy
```


## Github升级

有两个比较大的变化，文档并不是那么容易看清楚：

1. 存放页面的repository必须变为 **username.github.io**,原来的则是 **username.github.com**，可以到**settings**里边，做rename操作。  
1. 默认显示的页面来自于**master**,之前则是来自于**gh-pages** 修改Rakefile即可。  
