---
layout: post
title: "Haskell regular expression"
date: 2012-03-30 22:16
comments: true
categories: [haskell, regexp] 
---

正则表达式是文本解析处理的一大利器，因而大部分程序语言都以库的方式提供支持。在Haskell中，有多种不同的实现可供使用，详细看参考[wiki](http://www.haskell.org/haskellwiki/Regular_expressions), 他们的效率和支持的特性有些微的差异。但是作为一种**强类型**的**静态**/函数式语言，haskell的正则匹配可以借助返回值类型多态提供灵活的匹配结果。

<!--more-->

## 安装

Haskell的正则表达式库位于Text.Regex中 , Ubuntu默认的GHC中并没有提供正则表达式库，实际使用的时候可以根据需要选择一个版本，也可以通过`apt-get`来安装，如果使用`posix`版本的正则表达式库，可以下载安装**libghc-regex-posix-dev**:
    
        apt-get install libghc-regex-posix-dev

## 用法

和Perl中的正则表达式匹配操作符一样，正则库提供了`=~`操作来完成匹配。和其它语言不同的是，这个函数(`infix operator`)通过返回值多态提供灵活的功能。

1. 基本匹配 - 可以指定返回类型为Bool来判断是否匹配:  
``` haskell
let pat = "(foo[a-z]*bar|quxx)"
"A match with foodiabar after" =~ pat :: Bool  --True
"no match" =~ pat :: Bool -- False
```
2. 返回第一个匹配的子串或者空串：  
``` haskell
let pat = "(foo[a-z]*bar|quxx)"
"A match with foodiabar after" =~ pat :: String  --get "foodiabar"
"no match" =~ pat :: String -- get empty string
```
3. 返回匹配的上下文信息：   
``` haskell
let pat = "(foo[a-z]*bar|quxx)"
"A match with foodiabar after" =~ pat :: (String, String, String)
-- get ("A match with ", "foodiabar", " after")
"no match" =~ pat :: String 
-- get ("no match", "", "")
```
这里可以区分出是否有空串匹配。  
4. 返回更多信息：  
``` haskell
let pat = "(foo[a-z]*bar|quxx)"
"A match with foodiabar quxx after" =~ pat :: (String, String, String, [String])
-- get ("A match with ", "foodiabar", " quxx  after", ["foodiabar"])
"no match" =~ pat :: (String, String, String, [String])
-- get ("no match", "", "", [])
```
这里最后的一个String list可以用于返回子分组信息。  
5. 获取匹配字符的index信息和长度：  
``` haskell
let pat = "(foo[a-z]*bar|quxx)"
"A match with foodiabar after" =~ pat :: (Int, Int)
-- get (13, 9)
"no match" =~ pat :: (Int, Int)
-- get (-1,0) for no match
```

