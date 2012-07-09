---
layout: post
title: "Type/data/newtype in Haskell"
date: 2012-04-24 22:19
comments: true
categories: [haskell, type]
---

Haskell提供了抽象代数类型（Algebra Data Type）来完成对数据的封装；其中最直观的是 data 关键字声明，可以用C/C++中的struct/class 来类比。此外，我们还可以用 type 和 newtype 来定义一些数据抽象。type所定义的就是一个已有类型的别名，其主要作用就是为了提高代码的可读性，更清晰的传达代码的意图；而newtype则有一些细微的差异和特殊作用。

<!--more-->

## newtype 的定义要求

通过newtype定义新数据类型必须满足以下要求：  
1. 只能有一个构造函数，不过record语法是可以用的   
2. 只能封装一个字段  

看如下的例子：
```haskell
newtype State s a = State { runState :: s -> (s, a)}

-- this is not allowed
- newtype Pair a b = Pair { pariFst :: a, pairSnd :: b}
data Pair a b = Pair { pariSt :: a, pairSt :: b}

-- this is allowed
newtype Pair' a b = Pair' (a,b)
```
最后的一个例子中，封装的字段仅仅是一个tuple，所以仍然满足只有一个字段的要求。对于有多个构造函数的data类型，不能用对应的newtype来封装一个新类型。

既然`newtype`有这么多的不便，那么为什么会有人将其引入进来？对于newtype类型而言，一个最大的特点是，其构造函数在编译期间就被擦掉了，即运行期间，其构造函数是不可见的，其封装的类型和内部的field类型完全没有区别(对于类型系统而言）;这样就会有巨大的**性能优势**：newtype类型的数据既照顾了数据抽象和代码可读性的要求，又具有尽可能少的额外处理负担；当然这些好处也带来一些很微妙的问题。

考虑如下的例子：
``` haskell
newtype Feet = Feet Double
newtype Cm   = Cm Double
```
两种类型在运行期是没有办法相互区分的，但是在编译期间，他们是不同的type，编译器可以保证二者没有被混用；当然这个都是通过Haskell的Type checking来完成的。

## Laziness

对函数进行pattern match的时候，由于构造函数实际上已经不可见，因而对newtype的构造函数进行的匹配实际上会被忽略，但是对于data类型而言，构造函数的参数数据则必须被严格赋值,如下边的代码：

``` haskell
data Foo = Foo Int
newtype NewFoo = NewFoo Int

-- Argument is lazy, so undefined is not evaluated
x = case Foo undefined of 
    Foo _ -> 1
x1 = case NewFoo undefined of
    NewFoo _ -> 1

-- pattern match failure, so get undefined
y1 = case undefined of
        Foo _ -> 1

-- No constructor during runtime, so lazy to get 1
y2 = case undefined of
        NewFoo _ -> 1
```

## 参考
1. [Stack Overflow:Difference between data and newtype](http://stackoverflow.com/questions/5889696/difference-between-data-and-newtype-in-haskell)
2. [Haskell wiki](http://www.haskell.org/haskellwiki/Newtype)
3. [Stack Overflow: Why is there data and newtype in haskell](http://stackoverflow.com/questions/2649305/why-is-there-data-and-newtype-in-haskell/2650051#2650051)
