---
layout: post
title: "wireshark解密SNMPv3-DH包"
date: 2009-07-27 22:24
comments: true
categories: [wireshark, tools, tips, debugging]
tags: [wireshark, tools, tips, linux]
---

出于安全性的考虑，很多网络应用可能用比较强的安全算法加密传输的数据，从而导致抓包这一强大的网络分析工具成为鸡肋，SNMP v3就是这么个例子。
Wireshark自带有配置usmUser的例子，可以自动调用netsnmp的库来完成揭秘，但对于Unix程序而言，GUI的工具本身还是有诸多不便，没有CLI工具来的舒服自然，另外的一个问题是，通过自己配置usmUser，似乎一直无法成功解码。

翻看Wireshark的文档的时候，发现一个强大的小工具很适合配合脚本发挥威力：tshark；想到Python，马上实现了一个不错的小工具。

tshark本身可以支持很多选项，几乎涵盖了wireshark大部分常用功能，个人发现特别适合二次分析。这里最关键的是 -T pdml选项,可以生成一个完整的xml格式的分析报告。

假设实现用tcpdump或者snoop抓取了一个加密的包test.pcap,那么接下来，可以用其作二次分析：
``` bash
snoop -d <dev> -o test.pcap <filter>
tshark -r test.pcap -V -T pdml > test.xml
```

接下来可借助脚本的威力来解析这个xml文件了，python的xml.sax很适合干这个了，自己写一个ContentHandler， 将感兴趣的字段抓下来，存储在一个相关的结构里边。这里对于SNMP而言，只需要将对应的scopedPDU加密数据保存下来，同时保存其它必要的数据，放置于索引的dict中，便于下一步分析。

利用C/C++写一个小程序，接收加密参数、字段内容等参数完成实际解码工作，由于是API的简单调用和变换，所以比较简单；生成可执行文件即可。

最后，将上述通过python的 Popen建立I/O管道，将各个部分串联起来，并格式化每一步分析产生的输出结果，生成结果报告。


以上的方式可以不需要写dissector就完成自定义的报文分析，缺点是，运行效率比较低一些；优点也很明显，很容易定制和脚本自动化。
对于私有协议而言，上述方式也是一个不错的选择。

