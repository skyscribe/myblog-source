---
layout: post
title: "Ruby 学习笔记 6 - 正则表达式"
date: 2012-03-12 19:37
comments: true
categories: [ruby, 学习笔记, regexp]
---

文本处理是Python/Ruby这类脚本语言的重头戏之一，而强大的正则表达式支持对于文本处理来说也是必不可少的。Ruby的设计很多方面沿袭perl，正则表达式方面也不例外。

## 基本正则表达式

Ruby中的正则表达式有 2 种方式：

* 用'/'分隔的字符串('/' 本身需 '\/' 转义）  
``` ruby
/myPattern/mi
"Ruby matches uby" =~ /aTch/im #result is 6
```
* 用 %r 开头，然后以其后第一个字符为分隔符的串  
``` ruby
%r!/usr/local/!
"/usr/local/bin/" =~ %r!/usr/local/! # => 6
```
<!--more-->

## 基本元字符

* 基本控制字符包括 `^, $, ., +, ?, (), [], {}, |, \`, 涵盖了POSIX 扩展正则表达式中的所有元字符。除此之外的其它字符匹配其自身。  
* 一些特殊控制语法：  
    - \w, \W, \s, \S 分别对应word，non-word, space, non-space  
    - \d, \D 对应 digits, non-digits  
    - \Z, \z 对应字符串结束，\Z不包含换行符本身  
    - \b, \B 对应 word boundary, non-word boundary  
    - (?imx), (?-imx) 分别在大括号范围内打开关闭临时的modifier  
    - (?#) 用于添加comment

## Modifier

正则表达式中可以包含一个或者若干个modifier,用于控制整体匹配搜索行为，包括：  

- i 忽略大小写匹配   
- m 匹配多行，将\r\n当作普通字符  
- o 仅仅在第一次正则表达式被赋值的时候，执行一次#{}插入，这个选项用于控制替换一些ruby变量行为  
- x 类似于Python的verbose模式，允许插入注释，并且忽略所有的空格字符，包含\t\b\f\r\n\s  
- u/e/s/n Unicode/EUC/SJIS/ASCII 支持  

## 查找和替换

有 2 组函数用于完成同样的工作，以 **!** 结尾的函数会修改源字符串，另外的一个则返回一个新字符串。

- 替换函数： sub/gsub 前者仅仅匹配第一个，后者找到所有匹配  

``` ruby
1.9.2p290 :016 >   text = "Some string for test only, more..."
=> "Some string for test only, more..." 
1.9.2p290 :017 > text.sub('or', '|')
=> "Some string f| test only, more..." 
1.9.2p290 :018 > text.gsub('or', '|')
=> "Some string f| test only, m|e..." 
```
- 匹配： 用 **~** 来完成匹配

## Regexp 对象 

基本的正则表达式语法实际上对应着一个regexp对象，Regexp类定义了`match`函数，其返回一个MatchData 对象，即：
``` ruby
obj = /testRege[xX]p/i
obj.class #Regexp
mat = obj.match('testRegexp')
mat.class #MatchData
mat.regexp #/testRege[xX]p/i
```

MatchData 对象中的`length`可以用于查询group的数量，而`[]`则可以返回匹配部分的每一个`()`分隔的group, 其中`[0]`返回整个匹配的字符串，而[1]...[N]返回第N个子group. 例如：
``` ruby
pattern = /^(\w+)\s*=\s*(\w+)\s*(#*.*)$/
testStr1 = "key = value1"
testStr2 = "key = value2 #a comment"
mat1 = pattern.match(testStr1)
mat2 = pattern.match(testStr2)
#mat1.length = mat2.length = 4
# mat1[0] = "key = value1", mat1[1] = "key", mat1[2] = "value1", mat1[3] = ""
# mat2[0] = "key = value2 #a comment", mat2[1] = "key", mat2[2] = "value2", mat2[3] = "#a comment"
```

`offset`函数用于查询第N个子group的开始/结束 offset，参数为0时返回整个匹配的offset：

``` ruby
mat1.offset 0 # [0,12]
mat1.offset mat1.length - 1 #[12,12]
mat2.offset mat2.length - 1 #[13,23]
testStr2.slice(13, 23)  # "#a comment"
```

## 参考
1. [ruby regular expressions](http://www.tutorialspoint.com/ruby/ruby_regular_expressions.htm)
