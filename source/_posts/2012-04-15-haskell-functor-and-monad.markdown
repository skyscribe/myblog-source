---
layout: post
title: "Haskell Functor &amp; Monad"
date: 2012-04-15 21:11
comments: true
categories: [haskell, functor, monad]
---

作为一种函数式语言，haskell提供了各种高级的函数编程抽象支持：Functor抽象了那些作用于**函数（或者类型封装）内的数据的操作并且将其运算结果用对应函数封装的抽象运算**, 其核心是提供了**Functor** typeclass 和 **fmap**操作。

<!--more-->

## 一些基本抽象函数

在传统的函数式语言中，**map/filter/any**通常是最为builtin的高阶函数提供的，它们都携带一个函数作为第一个参数，并且作用于一个list作为第二个参数，并且返回满足条件的结果 - 或者是一个子list，或者是一个Bool，如下：

```haskell
Prelude> :type map
map :: (a -> b) -> [a] -> [b]
Prelude> :type fmap
fmap :: Functor f => (a -> b) -> f a -> f b
Prelude> :type filter
filter :: (a -> Bool) -> [a] -> [a]
Prelude> :type any
any :: (a -> Bool) -> [a] -> Bool
Prelude> :type all
all :: (a -> Bool) -> [a] -> Bool
```

这些函数的意义通常都比较简单明了，不过它们仅仅作用于list类型。对于更复杂的类型，譬如说一个wrapper类型，这些函数就无能为力了。

## 更高级的抽象 - Functor

考虑如下的例子，定义一个Tree类型：
```haskell
Tree a = Node (Tree a) (Tree a)
       | Leaf a
     deriving (Show)
```

这里的Tree中保存的是一个抽象数据。假设这里的a是个String，并且我们希望据此生成一个新的Tree，对应的每个节点中的数据存放的是对应String的长度，那么其实现可以如下：
``` haskell
treeLengths (Leaf s) = Leaf (length s)
treeLengths (Node l r) = Node (treeLengths l) (treeLengths r)
```
因为这里的length仅仅是一个作用于所封装的类型（String）的一个函数，一个很自然的想法是可以将这个函数操作本身抽象出来，生成一个抽象的TreeMap:
```haskell
treeMap :: (a->b) -> Tree a -> Tree b
treeMap f (Leaf a) = Leaf (f a)
treeMap f (Node l r) = Node (treeMap l) (treeMap r)
```

这里通过定义treeMap，实现将参数函数应用于ADT类型Tree中所封装的类型，将函数运算结果重新用Tree做封装。Functor就是绑定于某一个函数（譬如这里的Tree类型构造）之上并定义了一个**fmap**函数的typeclass：
```haskell
class Functor f where
    fmap :: (a->b) -> f a -> f b
```

通过上述定义，我们可以发现treeMap实际完成了famp的功能；自然地可以让Tree作为Functor的一个instance来继承这个Typeclass:
```haskell
instance Functor Tree where
    fmap = treeMap
```
## list & Maybe

Maybe类型是一个基本类型，用于封装某个数据或者空，而List则用于描述数据列表。对于List类型，其fmap对应的实现其实就是map - **fmap可以看作是map的一个扩展**; 对于Maybe类型，fmap的定义如下：
``` haskell
instance Functor Maybe where
    fmap _ Nothing = Nothing
    fmap f (Just x) = Just (f x)
```
也就是说，对于空数据，famp的结果仍然是空，而对于实际封装的数据，则返回Just封装的函数运算结果。

## Monad, liftM 和 ap

Monad 是一种特殊的typeclass，其封装的原始数据在任何运算过程中都不能暴露其中间运算结果，任何一个monadic函数返回的都是一个新的monadic变量；如果需要将一个纯函数作用于Monad所封装的数据类型，并得到一个对于元算结果的Monad封装，则需要用**liftM**:

```haskell
liftM :: (Monad m) => (a -> b) -> m a -> m b
liftM f m = m >>= \i -> return (f i)
```

对于多个变量的函数，haskell中定义了`liftM2`/`liftM3`...`liftM5`,以下是`liftM2`的定义：
``` haskell
liftM2 :: (Monad m) => (a->b->c) -> m a -> m b -> m c
liftM2 f m1 m2 = m1 >>= \a -> m2 >>= \b -> return (f a b)
```

这里的操作可以依次作用于2个monadic变量，并且得到一个新的moandic变量。对于无穷集合运算来说，liftM系列函数就无能无力了；这个时候 `ap`则可以派上用场：
``` haskell
ap :: Monad m => m (a -> b) -> m a -> m b
```

如下例：
``` haskell
data MovieReview = MovieReview {
      revTitle :: String
    , revUser :: String
    , revReview :: String
    }

lookup1 key alist = case lookup key alist of
                        Just (Just s@(_:_)) -> Just s
                        _ -> Nothing

apReview:: [(String, Maybe String)] -> Maybe MovieReview
apReview alist = MovieReview `liftM` lookup1 "title" alist
                    `ap` lookup1 "user" alist
                    `ap` lookup1 "review" alist


-- identical impl by liftM3
liftedReview alist = 
    liftM3 MovieReview (lookup1 "title" alist)
                       (lookup1 "user" alist)
                       (lookup1 "review" alist)
```
这里有2中等价的实现方式，而liftM结合ap的方式提供了更高的灵活性，可以直接扩展至多个参数的情形。

## 参考
- 例子来源于[real world haskell](http://book.realworldhaskell.org/)
