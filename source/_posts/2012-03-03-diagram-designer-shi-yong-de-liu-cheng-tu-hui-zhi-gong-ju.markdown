---
layout: post
title: "Diagram designer-实用的流程图绘制工具"
date: 2009-07-06 20:34
comments: true
categories: [tips, tools]
---

一直在留意好用的开源作图工具，可惜这年头很多是UML的，并且绑定与Eclipse的很多，可惜我需要的只是能够画基本的流程图，而且可以随意在矩形框之间加连接线，并且可以自动调整连接线的；最近突然发现了一款相当好用的开源工具，不仅小巧，而且速度快，自身相对独立，刚好合乎我的需要；也不需要蜗牛般的Java，真乃好东东。

<!--more-->

## 例子

下边是我做的图形：

![SNMP USM process messsage][1]

表示复杂的结构也很是漂亮，而且最关键的一点是，可以直接拷贝到PPT里边做成presentation。
下边是另外一个图，类似于UML里边的Sequence Diagram，当时又不完全是，不过可以清晰的表达我的意思了。
曾经想用Netbeans的UML插件画出类似的图像，可惜想自己加个方框都不行，还是这个灵活：

![SNMP USM discovery][2]

这个可爱的软件，简直可以和Visio媲美了，而且是开源免费的。
另外一个例子，作者提供的模板，也很漂亮，可以画电路硬件图的：

![official example][3]


还有一个UML的例子，看它的[官方网站](http://meesoft.logicnet.dk/DiagramDesigner/)描述。

## 综述

- 高级功能：自己定制模板，供以后使用。 
- 可以导出为几种常见的图片格式，以它自己的格式(ddd后缀）最节省空间。 
- 小缺点：折线箭头只能拐2个弯，因此不能一笔绘制回形箭头，需要手工拼接。 
- 最强大的地方：属性可以自由修改，因此超级灵活。

[1]: /images/USM_process_incoming_message.jpg "usm process incoming message"
[2]: /images/USM_Discovery.jpg "usm engineID/timeliness discovery"
[3]: /images/dd-official.jpg "DD official demo"

