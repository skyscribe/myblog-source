---
layout: post
title: "Pandoc转换技巧之从markdown到PDF"
date: 2013-02-02 20:52
comments: true
categories: [pandoc, markdown, pdf, latex, doc]
---

用Pandoc这一神器可以实现N多文档格式的转换，这里仅记录一些小技巧。

<!--more-->

## PDF输出控制

通过指定`-o xx.pdf`选项指定输出后缀为`.pdf`之后，pandoc就可以**自动**完成到PDF格式的转换，譬如：
```bash
#generte pdf from markdown
pandoc test.markdown -o test.pdf
```

PDF输出可以用以下格式来控制：  
- 生成TOC目录表 : 使用`--toc`  
- 控制生成的目录标题，使其自动编号。默认情况，**标题是不自动编号的**。  
``` bash
pandoc --toc --number-sections test.markdown -o test.pdf
``` 
- 生存beamer格式的幻灯片：  
``` bash
#--slide-level specifies the maximum title level
# -t beamer specifies beamer format for slide show
pandoc --slide-level=2 -t beamer test.markdown -o test.pdf
```
- 禁用pandoc的markdown扩展(采用标准markdown语法)： 
``` bash
#-f markdown_strcit[+feature]
pandoc -f markdown_strict test.markdown -o test.pdf
```

## latex 模板定制

用户可以通过指定一个自定义的latex模板文件来定制自己的PDF输出格式；在Windows下，这一文件位于`%appdata\pandoc\templates\default.latex`,对于Linux而言，对应的就是`$HOME`目录之后的相关子目录中。如果没有自定义模板，那么pandoc会使用系统默认的模板。

在这一模板文件中，我们可以定制自己的**preamble**部分，也可以自定义**header**, **title**等等。譬如，如果想在TOC后边自动换到一个新页面（默认情况没有分页），那么就可以在 `\toc`后边加上`\newpage`命令使正文部分从下一页开始。


