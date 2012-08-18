---
layout: post
title: "Curl&amp;SSL issues on Solaris"
date: 2009-07-27 22:29
comments: true
categories: [cpp, ssl]
---

源码编译libcurl的时候,由于使用的不是默认系统上的ssl库（开发服务器上有很多个版本），为了避免动态库链接问题，必须定制SSL。
根据其源码里边的说明，只需要在./configure 后边加上 --with-ssl=<path>即可。

开始的时候，没留意这个，因为粗略扫描了一下 --help, 后边这么说了：
```bash
--with-libssh2=PATH   Where to look for libssh2, PATH points to the
                      LIBSSH2 installation (default: /usr/local/lib); when
                      possible, set the PKG_CONFIG_PATH environment
                      variable instead of using this option
```

我的目标库的确就是在/usr/local/ssl下边了，当时编译之后，链接起来总是提示找不到对应版本的libssl.so.0.9.7.
后来才发现(将环境变量做小幅调整、改动来探测)，这个default在Solaris上边并不是真的default,必须显示指定为/usr/local/ssl,否则找到的居然是/usr/sfw/。


