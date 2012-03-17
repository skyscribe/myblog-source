---
layout: post
title: "Haskell type system exercises"
date: 2012-03-14 22:16
comments: true
categories: [haskell, study, 学习笔记]
---

Haskell的类型系统是**强类型**的，并且没有任何强制类型转换。所有的类型检查均在编译器做检查。定义新的数据类型之后，即使它们内在的数据结构完全一样，也是完全不同的数据类型，不能混用。

<!--more-->

## Maybe 类型

Maybe类型是有一种基于已有类型的二次封装类型，用于表述可能为空的抽象类型，用于支持类似于 C++/Java 中的模板机制，不过Haskell的类型系统表达能力比一般语言中的模板强大很多。

``` haskell
Maybe a = Just a | Nothing
```

## 新类型定义

- 可以采用`data`关键字来定义，*=*后边第一个标志符是其构造函数，用于构造新类型的实例对象。也可以用`type`来建立类型别名。不同的类型别名对用的新类型是不能互相转换的。

- 类型定义中可以用 `|` 来指定多个构造函数，这些构造函数最终都会生成同样类型的实例。

- 类型定义中，可以用record语法来提高可读性。

## 练习题解法

### toList 的实现：

``` haskell
data List a = Cons a (List a)
            | Nil
              deriving (Show)

fromList (x:xs) = Cons x (fromList xs)
fromList []     = Nil

-- my solution --
toList (Cons x (xs)) = x : toList xs
toList Nil = []
```

运行结果：

```
Prelude> :load ListADT.hs 
[1 of 1] Compiling Main             ( ListADT.hs, interpreted )
Ok, modules loaded: Main.
*Main> let alist = fromList [1..12]
*Main> alist
Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 (Cons 6 (Cons 7 (Cons 8 (Cons 9 (Cons 10 (Cons 11 (Cons 12 Nil)))))))))))
*Main> toList alist
[1,2,3,4,5,6,7,8,9,10,11,12]
```

### 用Maybe类型实现的模板树

已经给出的实现代码：

``` haskell
module Tree where
data Tree a = Node a (Tree a) (Tree a)
            | Empty
              deriving (Show)

simpleTree = Node "parent" (Node "left child" Empty Empty)
                           (Node "right child" Empty Empty)
```

- 采用Maybe的实现一：

``` haskell
data MyTree a = MyNode a (Maybe (MyTree a)) (Maybe (MyTree a))
                deriving (Show)

mySimpleTree = MyNode (Just "parent") (Just (MyNode (Just "left child") Nothing Nothing))
                                (Just (MyNode (Just "right child") Nothing Nothing))
```

- 采用Record语法提高可读性: 

``` haskell
data MyTreeRecord a = MyTreeRecord {
          parentNode  :: a
        , leftChild   :: Maybe (MyTreeRecord a)
        , rightChild  :: Maybe (MyTreeRecord a)
} deriving (Show)

anotherSimpleTree = MyTreeRecord {
    parentNode  = "parent"
   ,leftChild   = Just MyTreeRecord {
            parentNode  = "left child",
            leftChild   = Nothing,
            rightChild  = Nothing
        }
   ,rightChild  = Just MyTreeRecord {
            parentNode  = "right child",
            leftChild   = Nothing,
            rightChild  = Nothing
        }
}
```

运行结果：
```
Prelude> :load Tree.hs 
[1 of 1] Compiling Tree             ( Tree.hs, interpreted )
Ok, modules loaded: Tree.
*Tree> simpleTree 
Node "parent" (Node "left child" Empty Empty) (Node "right child" Empty Empty)
*Tree> mySimpleTree 
MyNode (Just "parent") (Just (MyNode (Just "left child") Nothing Nothing)) (Just (MyNode (Just "right child") Nothing Nothing))
*Tree> anotherSimpleTree 
MyTreeRecord {parentNode = "parent", leftChild = Just (MyTreeRecord {parentNode = "left child", leftChild = Nothing, rightChild = Nothing}), rightChild = Just (MyTreeRecord {parentNode = "right child", leftChild = Nothing, rightChild = Nothing})}
*Tree> 
```
