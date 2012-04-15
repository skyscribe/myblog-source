---
layout: post
title: "Haskell Monad"
date: 2012-03-23 20:38
comments: true
categories: [haskell, monad]
---

作为一个函数式强类型语言，Haskell 尽可能的保证提供纯函数特性，即任何操作都不会有副作用  - **给定相同的参数输入，给定函数必须产生相同的输出结果**;这个保证看起来很优美很干脆（容易测试并容易并行处理），但是现实世界中的问题确实则不能通过纯函数的方式解决，譬如IO输入输出，系统文件操作等；这些操作的过程依赖于调用时候的上下文环境，即给定完全相同的输入，不可能得到完全一样的输出，且不说中间可能会有其它副作用影响函数的行为，比如文件操作可能失败，IO 输出到特殊的终端的时候，可能出错等。

对于这类问题，Haskell 的处理方式是通过 Monad 将无副作用的部分（纯函数部分）和不纯粹的部分分离开。当然 Monad 的作用不仅仅限于此，其本身也可以用于封装某些复杂的处理，提供更高级的抽象，提高代码的模块化。

<!--more-->

## Monad 概念
Monad是一个从群论中（高等数学一个分支）借来的概念，对于没有很好数学基础的程序员来说，准确描述其概念相当有难度。我们可以从行为上来理解Monad，它是一种用于组织*作用于普通数值类型上的运算以及利用这些数值做一系列复杂运算的*结构化抽象。通过Monad，程序员可以用类似于命令式语言的方式来构建一些操作序列，这些操作序列本身可能又是一些复杂运算的操作序列。通过Monad，可以通过高度抽象的方式组合一些已有的操作从而生成一个新的操作序列，程序员可以依赖Monad来避免很多重复的code来完成类似的运算序列。

简单来说，可以将Monad看作为一种组后某些复杂操作为更高级复杂的操作的策略的一种抽象。很自然的，Monad可以用于描述带有状态的复杂操作，IO操作，多值返回等，但是需要注意的一点是Monad并不意味着其中的操作序列是顺序执行的，它们之间完全有可能是并行的。

Monad有如下重要特征和作用：   

* 模块化 - 可以将复杂操作的序列通过抽象的Monad来描述，从而将运算序列的定义和实际执行分离开    
* 灵活性 - 使得使用了Monad的程序灵活性更高，因为关于运算逻辑的策略部分和具体的元算定义是分开的       
* 隔离纯函数部分和有副作用的部分 - 尽可能的保证纯函数的操作部分不被有副作用的状态操作所污染   

## Monad 预备知识

理解Monad需要预先熟悉一些基本特性：   
- Type constructors   
用于定义新的多态数据类型，该类型包含有一个动态参数类型，比如Maybe类型定义：
``` haskell
data Maybe a = Nothing | Just a
```
这里的类型定义中包含一个可变参数`a`，用于表明这里定义的类型是一个类似于容器的抽象类型，包含一大类具体类型，譬如`Maybe Int`/`Maybe String`等等。其中的`constructor`可以生成两种不同的具体类型，要么是`Nothing`,要么是给定类型的一个wrapper类 `Just a`。

- type class  
用于类型的抽象，这里Monad本身就是一个typeclass.

## Monad 定义

Monad本身是一个type class，其定义如下所示：
``` haskell
class Monad m where
    (>>=) :: m a -> (a -> m b) -> m b
    return :: a -> m a
```

这里的代码揭示了 Monad 的三个基本要素：

1. Typeclass - Monad 本身是一个抽象的Typeclass，其中的m可以是某个具体的Monad类   
2. (>>=) - 又被称为 bind 操作，用于联合多个运算，将一个Monad类作为第一个参数，第二个参数是一个从数值类到Monad变量的一个运算，最终返回一个Monad变量     
3. return - 又成**unit**操作，将一个数值类wrapper为一个Monad变量    

比如Maybe的例子，有：
``` haskell
instance Monad Maybe where
    Nothing >>= f = Nothing
    (Just x) >>= f = f x
    return = Just
```
这里的`bind`操作对2个constructor有不同的实现（pattern match），而 return 直接作用于 Just constructor。

通过Haskell提供的 `do notation`, 可以对Monad做类似于命令式语言的操作：
``` haskell
data Sheep = SheepCreator String (Sheep, Sheep) | NONE
     deriving Show

father:: Sheep -> Maybe Sheep
father (SheepCreator name (NONE, _)) = Nothing
father (SheepCreator name (f, _)) = Just f

mother:: Sheep -> Maybe Sheep
mother (SheepCreator name (_, NONE)) = Nothing
mother (SheepCreator name (_, m)) = Just m

-- Following 2 functions are idential
fathersMaternalGrandmother :: Sheep -> Maybe Sheep
fathersMaternalGrandmother s = (return s) >>= father >>= mother >>= mother

fathersMaternalGrandmotherDo :: Sheep -> Maybe Sheep
fathersMaternalGrandmotherDo s = do f <- father s
                                    mf <- mother f
                                    mmf <- mother mf
                                    return mmf
```

这里的Do方式可以极大的提高代码的可读性。实际上Do之间的代码会被Haskell编译器替换为等价的bind方式，即**DO notation 仅仅是一种语法糖**.需要注意的是，DO里边的操作未必保证是顺序执行的，Haskell仅仅保证满足lazy evaluation即可，即前边的变量如果没有被后边一个用到，两个语句可能是并行执行的。

Monad 类必须要满足三个基本定律才能用DO来表达(具体的论证需要群论的数学知识):  

## Monad 基本定律

1. return 对于 bind 而言是左相等，即： `(return x) >>= f == f x`  
2. return 对于 bind 保持右相等，即: `m >>= return == m`   
3. 结合律： `(m >>= f) >>= g == m >>= (\x -> f x >>= g)`   

可以注意到的是，Monad里边的所有操作函数都返回Monad变量，而不会直接返回一个数值类型变量。其目的是为了隔离所有具有副作用的操作于Monad之中，每次操作都返回Monad可以避免将有副作用的代码混合到纯函数式代码中去。

## 其它Monad操作

标准Monad类还定义了其它类型的操作 - 这些是非必须的：  

1. fail 错误处理，Do里边的任何错误都默认立刻推出处理 - `fail s = error`   
2. `>>` 操作用于表述不需要前一个Monadic操作提供输入的处理:    
``` haskell
(>>) :: m a -> m b -> m b
m >> k = m >>= (\_ -> k)
```

## 其它的Monad定律

除了上述的3个基本定律，某些Monad还提供一下额外的保证：  
``` haskell
mzero >>= f == mzero
m >>= (\x -> mzero) == mzero
mzero `mplus` m == m
m `mplus` mzero == m
```
这里的`mzero`是一个特殊的monad变量，其满足对于左右bind的函数都返回`mzero`，而`plus`则返回两个参数中的任意一个非mzero的变量。在Haskell中满足这两的定律的类是MonadPlus:
``` haskell
class (Monad m) => MonadPlus m where
    mzero::m a
    mplus::m a -> m a -> m a
```

对于Maybe类型，其同样满足MonadPlus要求，对应的：
``` haskell
instance MonadPlus Maybe a where
    mzero = Nothing
    Nothing `mplus` x = x
    x `mplus` _       = x
```

* 可以想象mzero对应于算术运算中的0, mplus对应于(+).  
* Maybe在标准Haskell库里边已有定义   

## 预定义Monad

Haskell的**prelude**中预定义了一些Monad类型，包括：  
- Maybe   
- List Monad  
- IO Monad  处理IO操作  
- State  
- 其它  

## 参考资料
1. [A gentle introduction to Monad](http://www.haskell.org/tutorial/monads.html)
2. [Haskell twiki on Monad](http://www.haskell.org/haskellwiki/Monad)
3. [Yet Another Monad Tutorial](http://mvanier.livejournal.com/3917.html)
