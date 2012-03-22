---
layout: post
title: "Haskell typeclass"
date: 2012-03-22 20:15
comments: true
categories: [haskell, type]
---

Haskell 中也有class关键字，但其目的却和 OO 中的类有着巨大的差别。在 OO 世界中，类用来描述一大堆具有共同数据和行为的对象的抽象；而 Haskell 中的 class 则是用于抽象提供同样函数接口的数据类型。每一个 ADT 都可以用`instance`来生命其满足某个 class 并且给出对应于具体函数的实现，即 class 在 Haskell 中实际用于约束数据类型，因而又被成为 typeclass.

<!--more-->

## typeclass 的作用

由于 Haskell 是一个纯函数式语言，所有的操作都是用函数方式实现的（递归和模式匹配）；同时作为一个强类型语言，所以函数的参数必须绑定于特定的类型，而不同的数据类型之间是不能直接转换的 ( 需要转的也必须通过某些函数来实现 ), 那么对于同样一个类似的函数，可能就需要对不同的类型有不同的实现，因为操作的类型可能不同，这样就会带来很繁琐的代码，例如：

``` haskell
someOpOnInt::Int -> Int
someOpOnDouble::Double->Int
someOpOnFractional::Fractional-> Int
```

由于他们所做的操作本质上相同，但是由于强类型系统的制约，编写者必须给出不同的函数名来对应于不同的类型，后果就是重复的代码乃至糟糕的代码质量。另一个可能的问题则是对于每一个新定义的类型，必须定义一个新的函数。其它的模块想要调用此功能也必须针对不同的类型做不同的处理，导致代码不能重用。

Typeclass则可以很好的解决这个问题：
- 一个 typeclass 来定义所支持的操作，例如  
``` haskell
class SomeOp a where
    someOp :: a -> Int
```

- 每一个可以支持该操作的类型可以实现对应的操作，如：  
``` haskell
instance SomeOp Int where
    -- implementition for Int type
    someOp x = undefined

instance SomeOp Double where
    -- implementation for Double
    someOp x = undefined

instance SomeOp Fractional where
    -- implementation for Fractional
    someOp x = undefined
```

- typeclass是开放的，这意味着你可以在不同的模块里边实现其它模块中定义的 typeclass   
``` haskell
data BrandNewType = BrandNewType String Int
        deriving (Show, Eq)

instance SomeOp BrandNewType where
    -- imp for new type
    someOp x = undefined
```

由于 typeclass 实现的是对于 type 的抽象，如果熟悉 C++ 的模板系统和被 C++ 被拖出新标准的 [**concept**](http://en.wikipedia.org/wiki/Concepts_%28C%2B%2B%29) 概念，那么我们就容易发现 typeclass 和模板系统有很多的相似基因。而 typeclass 能够更优雅的抽象类型接口，则得益于 Haskell 的强类型系统了。想想 C++ 中隐式类型转换给模板实现带来的困扰，Haskell 的 typeclass 是一种更优雅的抽象。

## Read 和 Show

这是两个系统预定义的 typeclass, Show 用于将某个类型转换为 string， 而 Read 则用于从一个字符串表述中构造一个指定类型的数据。二者结合可以完成数据的序列化和反序列化。系统提供的 putStrLn 操作于某个数据类型的时候，如果其类型继承了 Show，那么它的字符串表示就会被打印出来。当然`show` 函数也可以用于打印其字符串表述，而 Read 则用构造出一个指定类型的对象，比如：

``` haskell
data Color = Read | Green | Blue
instance Show Color where
    show Red = "Red"
    show Green = "Green"
    show Blue = "Blue"

instance Read Color where 
    readsPrec _ value =
        tryParse [("Red", Red), ("Green", Green), ("Blue", Blue)]
        where tryParse [] = []
              tryParse ((attempt, result) : xs) = 
                if ( take (length attempt) trimed) == attempt
                then [(result, drop (length attempt) trimed)]
                else tryParse xs
              where trimed = lTrim value

lTrim (' ':xs) = lTrim xs
lTrim other = other

-- test in ghci
*Main> let inst = [Red, Blue, Green]
*Main> show inst
"[Red,Blue,Green]"
*Main> let inst' = read (show inst) :: [Color]
*Main> inst'
[Red,Blue,Green]
```

这里对于 list 类型的处理可以被系统自动推倒出来。

## 系统预定义的 typeclass

Haskell 标准规定编译器需要预定义一些基本的 typeclass， 并且对于系统预定义的数据类型，编译器也给出了对应的实现。这些预定义 typeclass 包括：
- Read - 数据反序列化   
- Show - 数据序列化    
- Ord  - 排序支持，描述顺序关系    
- Enum - 枚举接口     
- Eq   - 相等关系    

对于自己定义的 ADT， 这些 typeclass  可以用 deriving 的方式交给Haskell编译器来自动推导，省却了诸多麻烦。限制条件是，我们自己用`data`声明的ADT类型必须满足： **其中引用的类型必须也满足需要derive的typeclass**，这些类型可以是手动声明的方式满足typeclass.

如下的例子就是一个例外情况：
```haskell
data CannotShow = CannotShow
    deriving (Show)

data CannotDeriveShow = CannotDeriveShow CannotShow
    deriving (Show)

-- this will work
data OK = OK
instance Show OK where show _ = "OK"
data ThisWorks = ThisWorks OK
    deriving (Show)
```
这里的第一个例子中，引用的类型没有去指明继承 typeclass 因而会导致编译失败，而第二个类型则可以。

## 问题 - overlapping

由于 typeclass 是开放的， 不同的模块可能对不同的类型提供不同的 typeclass instance实现，二者就可能出现冲突，例如：

``` haskell
class Borked a where 
    bork:: a -> String

instance Borked Int where
    bork = show

instance Borked (Int, Int) where
    bork (a,b) = bork a ++ ", " ++ bork b

instance (Borked a, Borked b) => Borked (a,b) where
    bork (a,b) = ">>" ++ bork a ++ ", " ++ bork b ++ "<<"
```

如果我们需要调用`bork (1,2)`, 这里 haskell 编译器没法自动判断该选择那一个实现，因为最后两个都同样满足instance条件。GHC 中可以通过扩展 `OverlappingInstance` 来解除这一限制，引导编译器选择最具体的类型实现。
