---
layout: post
title: "snmp vacm view API的一个小bug"
date: 2012-02-29 20:40
comments: true
categories: [snmp, C, tips]
tags: [snmp, tips]
---

最近在查一个SNMP协议模块退出时, 发现[NET-SNMP](http://www.net-snmp.org/) VACM模块在退出的时候总是报view删除失败。仔细检查了API调用的代码，却始终没发现明显的问题。程序的逻辑大概可以简化为这样：

## 问题

1. 初始化的时候，动态创建VACM的view/group/access   
2. 退出的时候，调用VACM对应的destroy API释放资源    

    1. 释放之后，重新调用其get接口，确认是否仍然存在  
    2. 如果get到，说明释放失败，打印错误log  
    3. 否则正常退出  

上述逻辑对三种资源的操作方式都类似;其它两种资源在destroy之后都能成功释放;问题出在释放view之后，仍然能通过get得到之前创建的资源。

<!--more-->

## 排除步骤

- 首先怀疑是API调用的参数不对，但是仔细检查了create和destroy对应的API传入参数确认相同
- 排除API的调用参数问题，只能是SNMP的API本身实现有问题了。挂上gdb调试之，将断点设置于destroy内部，对比代码step down，最后发现**destroy根本就没有成功**,因为其是void函数，根本没有任何错误提示。

再看create/destroy的代码，才发现两个API的签名虽然类似，其实内部对参数的处理约定却不同：
{% gist 1940772 %}

create函数中，对viewSubtree/viewSubtreeLen的约定是，指针指向的是一个oid字符串，对应长度是字符串实际长度。内部create一个新的结构指针，对应的同名数据成员指针存放的内容采用Len-content的格式，即第一个字节保存后边字符串的长度，长度字段则等于内容长度+1

destroy函数的处理如下：

{% gist 1940778 %}

这里的处理却约定参数传入的viewSubtree/viewSubtreeLen是内部的结构体成员对应的结构，直接拿来memcmp了而没有考虑这是一个可能被外部调用的API。不查看这段代码的话是不可能知道这个隐藏的问题。

## 问题解决

找到问题的原因就容易解决了，不外乎两种方式:

1. 提供满足要求的参数，但是这里会造成create/destroy函数的参数有些不一致，并且暴露了API的内部细节  
2. 用其它方式得到内部数据，然后再传入。这是一种更合理的方式，先调用一下get，返回内部的数据结构体，然后传成员指针即可。  

## 其它

我们用的是NET-SNMP 5.5的代码，查看了5.5.1的代码（5.5版本的最新包),问题依旧。可惜它的代码在sourceforge上，提交patch很麻烦；暂时先这样了。

设计API的时候，create/delete的参数约定应该是对称的，这里显然是NET-SNMP犯了个小错误。

