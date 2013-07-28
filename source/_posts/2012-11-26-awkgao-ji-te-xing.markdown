---
layout: post
title: "awk高级特性"
date: 2012-11-26 19:49
comments: true
categories: awk, regexp, array, unix
---

UNIX环境下，用shell做一些常见的文本处理工作是很方便高效的事情；虽然目前有很多自带丰富类库的脚本语言可以完成同样的事情，但是对于一些特殊的文本格式处理任务，传统的sed/awk/grep组合还是有很明显的优势：没有复杂的版本问题和类库部署依赖问题，能够快速解决问题。awk作为一门**DSL**，自身也带有对很多**高级特性**（相对于shell本身）的支持，灵活应用往往能收到奇效。

<!--more-->

array类型
==================

awk自身支持类似于C语言数组的数据结构，称之为**array**，但是其下标却不仅仅限于数字，可以是字符串等其它类型；行为上来说更似于一个关联容器，从某个变量关联到另外一个变量：

``` bash
awk 'BEGIN{
    arr['aa'] = 1
    arr[4] = 2
    print arr['aa']
}'

```

基本的array操作：

* 遍历元素

``` bash
awk 'BEGIN{
    arr[1] = "cc"
    arr[2] = "ddd"
    arr['ccd'] = "demo"
    for (i in arr){
        print arr[i]
    }
}'
```

* 多维数组 - 多个下表操作内部会被转换为**SUBSEP**连接的字符串为索引的array:

{% include_code array.awk lang:bash awk_array.awk %}

需要获取具体下标的时候，可以使用`split`函数，传入**SUBSEP**作为分隔符，依次取得每一个下标。用于数据统计的时候，这一技巧相当顺手好用。


字符串操作和正则表达式技巧
==========================

字符串操作和C语言非常类似，可以使用：

* `substr` 取得子串，和很多脚本语言类似，传入一个源字串，初始下标和长度，例如：

``` bash
awk 'BEGIN{
    teststr = "this is a test string..."
    printf("<%s>\n", substr(teststr, 1, length(teststr) - 1));
    printf("<%s>\n", substr(teststr, 0, length(teststr) - 1));
}'
```
这里的第二个`printf`传入的下标从0开始，那么实际上得到的字串从末尾处被截去了2个字符。

* `length`可以取得字符串长度信息  


正则表达式regexp
------------------
基本的类**sed**类操作正如其名称所示(部分操作可以省略源字符串，默认等同于和`$0`相匹配）

* `sub` 用于正则替换左数起第一个匹配

``` bash
echo "The lazy dog" | awk '{sub(/[ey] /, "lagggg> ");print}'
#Thlagggg> lazy dog
```

* `gsub` 用于全局替换,所有满足条件的部分都被替换  

``` bash
echo "The lazy dog" | awk '{gsub(/[ey] /, "lagggg> ");print}'
Thlagggg> lazlagggg> dog
```


* `gensub` 是一个更通用形式的正则替换操作,它保持源字符串不动，将修改后的串返回

``` bash
echo "The lazy dog" | gawk '{new = gensub(/[ey] /, "lagggg> ", "g");print; print new}'
#The lazy dog
#Thlagggg> lazlagggg> dog
```

* `match` 可用于模式匹配并返回匹结果的开始下标，并设置**RSTART**为匹配到的下标，**RLENGTH**为匹配字串的长度

```bash
echo "The lazy dog jump over the brown fox" | awk '{
result = match($0, /(dog)(.*)(fox)/)
print result, RSTART, RLENGTH
print substr($0, RSTART, RLENGTH)
> }'
#10 10 27
#dog jump over the brown fox
```

脚本内嵌和独立awk文件
======================
一般可以将不太长的awk脚本处理放入管道操作中，让后用`'`来包含实际的awk处理脚本。当awk脚本过长的时候或者为了便于维护，也可以用一个独立的脚本来存放awk脚本内容，但是其shebang部分应该设置为： `#!/usr/bin/awk -f`, 这里的 `-f`表示后边的内容是awk脚本文件。

