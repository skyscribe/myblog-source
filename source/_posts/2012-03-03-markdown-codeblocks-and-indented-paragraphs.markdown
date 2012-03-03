---
layout: post
title: "Markdown codeblocks and indented paragraphs"
date: 2012-03-03 10:25
comments: true
categories: [markdown, tips]
---

## 错落的格式

**Markdown**是一种很简单灵活的标记工具，其语法在[官方文档](http://daringfireball.net/projects/markdown/syntax)里边有很详细的描述。不过我在使用其语法进行markup的时候发现段落缩进和**codeblock**同时使用的时候，有些奇怪的行为。如果希望下一个子段落保持缩进并且同时放置一个代码块，则格式可能就变混乱起来。譬如：

{% codeblock %}
- Test title
    test indented paragraph, with some ruby code
        
        puts "hello"
{% endcodeblock %}

将产生如下的输出:

------------------
Test title

    test indented paragraph, with some ruby code
        
        puts "hello"
------------------

<!--more-->
上述输出中，子段落部分显然不是我们希望的codeblock。

## 问题解决方法
看了文档后，想到了一种workaround： 在将要缩进的子段落的前一行最后加2个额外的空格，即可避免下边的子段落被当作codeblocks。

下边是修改后的效果 - (`Test title`之后加入**2个以上空格字符**)  

------------------
- Test title  
    Test indented paragraph, with some ruby code  
        puts "hello"

    Another sub paragraph  

    A third paragraph
------------------

## 限制和问题

测试表明，以上方法仅仅对list的子段落有用。
