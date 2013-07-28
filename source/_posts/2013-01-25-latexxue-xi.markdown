---
layout: post
title: "latex初探"
date: 2013-01-25 21:43
comments: true
categories: [latex, tex, doc, pandoc, markdown]
---

文档悖论
==========
每个程序员都讨厌没有文档的代码，然而没有几个程序员喜欢给自己的代码附上文档，因为写文档实在是太烦人的事情了，纠结的排版，目录，引用等等。然而很多时候，有个系统的文档来描述大块的代码设计可以减少很多无谓的脑细胞伤亡。Markdown作为程序员的文档格式工具，已经逐渐被很多人接受，但是仍然有许多“传统”的势力更喜欢“老旧”的word格式文档（或者PDF）。Markdown的好处是显而易见的:    

- 纯文本的格式，便于维护  
- 可以放入版本控制系统中，进行比较/评审/合并，有利于协作  
- 可以方便的转换为HTML  
- 格式和排版分离，使用CSS来控制排版  

简单的想法就是仍然用Markdown来书写文档，但是**利用工具将文档翻译成HTML或者PDF输出**。喜欢老旧格式的仍然可以看PDF，新潮一点的就直接用HTML在浏览器查看就解决了；就像Python的代码，既可以通过工具转换为机器码直接执行，也可以在装有解释器的机器上用字节码运行。生成HTML的方法无需赘述，网上已经有大把的资料参考，然而如果想**方便的转换为PDF，却不是那么容易的事情**了。

<!--more-->

生成PDF
--------
PDF的跨平台特性和漂亮的排版实在是诱人，可惜大部分Markdown工具都不支持很方便的直接导出PDF工具。查了下google和Stackoverflow，大部分的建议都指向了**Pandoc**，所以要想得到漂亮而又可移植性好的PDF文件，还是得找pandoc。

Pandoc
--------
Pandoc是一个用**Haskell**写就的库，在Windows上安装，则直接到[官网下载页面](http://johnmacfarlane.net/pandoc/installing.html)选择安装就是了。这是一个大神器，可以在数十种文档格式之间进行双向转换，其转换能力形象一点的表述如下图[!pandoc formats](http://johnmacfarlane.net/pandoc/diagram.png "Pandoc format diagram")

windwos平台的安装还需安装Tex工具，都是Exe格式的安装包。装完之后，根据其文档，如下的命令就可以简单的生成PDF文档了（还是写个Makefile方便一些吧）:  

``` make
target: test.markdown test.pdf test.html
    echo "done"

%.pdf : %.markdown
    #pandoc --highlight-style=pygments -t beamer -o $@ $<
    pandoc --highlight-stylee=pygments --listings  -o $@ $<

%.html : %.markdown
    pandoc --highlightt-style pygments -t html5 -o $@ $<

clean:
    rm -fr *.pdf *.htm *.html
```

最简单的转化自不必说，没错的话，PDF已经给你生成好了。但是当你面对一个比较大的markdown文件的时候，Pandoc的转换可能就不那么好玩儿了，出错的东东都在tex里头；当然你可能也会有其它的想法，比如生成的PDF格式想多定制一些东西，那么必须面对latex模板修改的问题。要想根本上解决这个问题，还是得从根源上学起；所以还是仔细学学Latex吧。

Windwos上安装Tex工具有不少选择，官网推荐的exe装好之后会提示很多TEX包丢失的问题，一个一个安装很是费劲（尤其是网络不好的情况），相比较而言，TexLive2012的DVD ISO安装模式要省心不少了，这里也就不再罗嗦了。还是Ubuntu上来的简单(texlive-*),强悍的`apt-get`命令解决了所有的麻烦。当然Linux下的Pandoc可能不是最新版本，如果需要新版本，可能需要安装完整的Haskell平台，不过这个已经不是什么问题了；爱捣鼓的早就安装了Haskell这个阳春白雪的神语言工具了。

latex初探
==========

最基本任务 -- Hello World
---------------------------
最简单的文件非**hello world**莫属了，但是需要生成hello world也还是需要不少基本的工作的；当然比起word里边敲敲字符要费劲一些，但是短期的痛苦只是为了长久的便利。完成这个最简单的任务大概是需要这些：
``` tex
\documentclass{article}
\begin{document}
Hello world
\end{document}
```
Tex的语法看起来和正式的变成语言类似，所有的命令都已`\`来开始，如果命令需要携带参数的话，就用`{}`传入进去就是。在`\begin`和`\end`之间的部分就是文档的正文，正文之前的那些命令被认为是关于整个文档的一些控制，譬如使用某些额外的包等。这里仅仅指定本文用的模板是`article`模式。
 
基本文档结构
---------------
在`\begin`和`\end`之间的部分是对应文档的内容了。文档的内容组织可以用段落和子段落的方式来组织，默认对段落是自动标号的，譬如下边的代码：  

``` tex
%preambles
\documentclass{article}
\usepackage{times}
\usepackage{lipsum}

%The actual document
\begin{document}

%The title part with author command
\title{How to Structure a \LaTeX{} Document}
\author{Andrew Roberts\\
  School of Computing,\\
  University of Leeds,\\
  Leeds,\\
  United Kingdom,\\
  LS2 1HE\\
  \texttt{andyr@comp.leeds.ac.uk}}
\date{\today}
\maketitle

\begin{abstract}
Your abstract goes here.. 
\end{abstract}

\section{introduction}
Some introduction text
\lipsum[1]

\subsection{Product background}
\lipsum[2]

\subsubsection{The history of this feature}
\lipsum[3]

\subsection{General decisions}
\lipsum[4]

\section{Impacts to other parts}
\lipsum[5-6]

\subsection*{Impacts to module1}
\lipsum[1-3]

\subsection*{Impacts to module2}
\lipsum[2-3]

\paragraph{Detailed impacts}
\subparagraph{details go here}
\lipsum[3-6]

\section{Design considerations}
\lipsum[7]

\end{document}
```

- 文档分层结构  
   类似于Word中的项目符号和编号，TEX中可以通过`section`的方式来实现，二级标题则使用`subsection`标识，`subsubsection`则为三级标题，`paragraph`和`subparagraph`则为正文的四级和五级。对应的分级子标题是自动编号的，如果不想加数字编号，则可以在参数前边加上**\***来标注。

- 标题  
   可以通过`title`命令来指定文档标题；然后`author`可以加入作者信息,`date`插入日期，`maketitle`来生成标题。  

- 摘要   
   生成摘要信息，仅需要将相关的文本嵌入`\begin{abstract}`和`\end{abstract}`即可。  

- 随机文本  
   [lipsum](http://www.lipsum.com/)命令可以简单的生成随机文本，便于测试文档结构。  


引用和参考文献
-----------------

引用参考文献和索引是正式文档必不可少的部分，TEX通过两种方式提供这一支持：  
- 将引用文献保存在一个单独文件中，然后通过一些命令在文档中插入引用；大型的文档较多采用这一方式   
- 在文档中直接引用参考文献;这一方式简单，却没有很好的扩展性，**下边详细描述这种方式**   

1. 定义  
   在文档结束之后，可以通过`\begin{thebibliography}{9}`的格式来定义参考文献列表，其后用`\end{thebibliography}'结束，譬如如下例子：   

``` tex
\begin{thebibliography}{9}
    \bibitem{autha91}
    some auther, 
    \emph{\Latex: the title}.
    Some publishers,
    1st Edition, 
    1991.
\end{thebibliography}
```

   这里的第二个参数定义了参考文献的个数，但是实际上定义了索引号码的宽度，因为小于10个的仅需一列就够用了，反之则需要多列；这样可以保证所以的对齐。每一个条目用`bibitem`来表示，其中对应的参数可以在文中用引用的方式来加索引。

   实际需要引用该文档的时候，只要用`\cite{citekey}`命令来标注即可。这里的`citekey`对应的就是上述的对应条目。


参考资料
============
1. [Andrew Roberts : Getting to Grips with LaTeX](http://www.andy-roberts.net/writing/latex)  
1. [TexLive2012](http://www.tug.org/texlive/)
1. [Lipsum](http://www.lipsum.com/)
