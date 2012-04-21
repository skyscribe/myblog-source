---
layout: post
title: "Haskell Functor/Applicative Functor"
date: 2012-04-18 20:19
comments: true
categories: [haskell, monad, functional]
---

Haskell中存在三种层次的函数过程抽象，依据约束的多少分别有 Functor， Applicative 和 Monad。Functor是一种最基本的调用提升，通过`fmap`可以将传入参数函数作用于所wrapper的type；而Applicative和Monad则定义了更多的运算符和原子函数等。

<!--more-->

## Functor

```haskell
fmap :: Functor f => (a->b) -> f a -> f b
```

Functor定义为一个Typecalss，其定义了一个fmap函数，对于对应的Type instance，a/b为构造函数参数变量，fmap将type变量中的a通过参数函数映射为变量b，并进而生成一个新的ADT变量。

假设 `g :: ( a -> b)`,那么 `fmap g (f a) = f (g a) = f b`。

GHC自带的很多基本**ADT**满足Functor的要求，即他们自身是Functor的实例，包括Maybe, list([]), IO Monad, Either等。

``` haskell
fmap :: Functor f => (a->b) -> f a -> f b
fmap (+1) (Just 1) 
-- Just 2, type = Maybe, constructor = Just
fmap (*2) [1,2,3,4]
-- [2,4,6,8], type = []
fmap (+2) (Left 2)
-- Left 4, type = Either, constructor = Left
fmap (+2) (Right 2)
-- Right 4, type = Either, constructor = Right 
fmap (*2) (1,2)
-- (1,4), type = ((,) a)
```

### Functor 定律

fmap需要满足以下约束条件：
```
fmap id = id
fmap (f . g)  = fmap f . fmap g 
```

不满足以上定律的ADT，如果声明了满足Functor，用fmap方式操作的时候可能产生错误的行为。

### fmap 的局限性

在Haskell中，所有的函数都可以视为只带一个参数，其余的参数可以通过 **currying** 来视为以第一个参数为参数，返回以其它剩余参数为参数的一个函数，即 `a -> b -> c` 也可看作一个以 `a` 为参数返回一个 ` b -> c `的函数的函数。考虑如下的例子：
```haskell
ghci>let a = fmap (^) [1..10]
ghci>:type a
a :: [Integer -> Integer]
ghci>fmap (\f -> f 2) a
[1,4,9,16,25,36,49,64,81,100]
```
因为传入fmap的函数参数为: `(^) :: (Num a, Integral b) => a -> b -> a`, 数据类型为 `list`, 于是，fmap的结果则是一个list类型，其中的元素参数为一个函数。对于这个list再次调用**fmap**, 那么对应的函数就是一个基于函数的函数 (**lambda**描述为 `\f -> f 2`), 结果就是将对应的lambda 函数作用于list中的每一个函数，生成最终的list 数据。这里的2次fmap调用得到的结果始终是一个list, 只不过每次的list具体数据类型有所不同。

如果想将`fmap`作用于一个不同类型的ADT数据 (Context)，那么编译器机会报错：
``` haskell
ghci>fmap Just (^2) Just 5

<interactive>:1:6:
    Couldn't match expected type `t1 -> t0' with actual type `Maybe a0'
    Expected type: a0 -> t1 -> t0
      Actual type: a0 -> Maybe a0
    In the first argument of `fmap', namely `Just'
    In the expression: fmap Just (^ 2) Just 5
```
而Applicativeze则可以很好的解决这个难题。

## Applicative

Applicative定义于`Control.Applicative`模块中，其自身定义于Functor之上（即对应的ADT首先应该满足Functor要求）,并且定义了更多的操作函数：
```haskell
class Functor f => Applicative f where
    pure :: a -> f a
    (<*>) :: f (a -> b) -> f a -> f b
    (*>) :: f a -> f b -> f b
    (<*) :: f a -> f b -> f a
```

`pure`比较简单，将ADT的构造函数变量a直接作用于Functor本身的构造函数`f`，返回具体的ADT变量`f a`.

`<*>`函数就是具体的applicative函数，其类型可以做如下简化：假设`g :: (a -> b)`, 则 `f g <*> (f a) = f ( g a) = f b`。`<*`和 `*>`则不需要对应的函数作用，仅仅返回左边或者右边的ADT变量。下边是一些具体的例子：

```haskell
Just (*3) <*> Just 2 
-- Just 6 : Just (2 * 3)
pure (*3) <*> Just 2
-- Just 6, equals to previous example
pure (+) <*> Just 3 <*> Just 5
-- Just 7
```

上述最后一个例子中，Haskell的currying特性得以应用，对于带有多个参数的函数，可以认为它只带一个参数，其它的可以根据一次传入的参数类型来替换，即:
```haskell
:type pure (+)
-- (Applicative f, Num a) => f (a-> a -> a)
:type (pure (+) <*>)
-- (Applicative f, Num a) => f a ->  f (a -> a)
:type (pure (+) <*> Just 3)
-- (Applicative f, Num a) => Maybe (a -> a)
:type (pure (+) <*> Just 3 <*>)
-- (Applicative f, Num a) => Maybe b -> Maybe b
```

对于对个参数的情况，Applicative可以通过`<*>`来依次传入对应的参数，并应用于对应的变换函数，最后将得到的结果用Functor的构造生成新的ADT变量。从上边的例子其实可以得出，`pure f <*> x = fmap f x`;因此Applicative定义了`<$>`来简化书写，即最后一个例子等价于
```haskell
(+) <$> Just 3 <*> Just 4
```

### `<*` 和 `*>` 及 const

`<*`和`*>`的类型表明它忽略函数的右侧或者左侧参数数值，但是对应的容器类型(f)没有发生变化。比如如下的例子：
``` haskell
ghci>:info <*
class Functor f => Applicative f where
  ...
    (<*) :: f a -> f b -> f a
        -- Defined in Control.Applicative
infixl 4 <*

ghci>Just 2 <* Just 1
Just 2
ghci>:t (Just (+2) <* )
(Just (+2) <* ) :: Num a => Maybe b -> Maybe (a -> a)
ghci>:t (Just (+2) <* Just 2)
(Just (+2) <* Just 2) :: Num a => Maybe (a -> a)
ghci>:t (Just (+2) <* Just 2 <*> Just 1)
(Just (+2) <* Just 2 <*> Just 1) :: Num b => Maybe b
gci>Just (+2) <* Just 2 <*> Just 1
Just 3
```

可见`<*` 是忽略函数右侧的其它参数，返回左侧。`*>`则和其相反：
``` haskell
ghci>Just (+2) *> Just 1
Just 1
```

Haskell有如下的`const`函数，因此 `<*` `*>`可以有 `<*>` 和`const`来实现:
``` haskell
ghci>:info const 
const :: a -> b -> a    -- Defined in GHC.Base
f *> g = flip const <$> f <*> g
f <* g = const <$> f <*> g
```

### list applicative

list类型本身是Applicative的一个instance, 但它的实现和Maybe有些不同，主要在于`<*>`的实现上可以有多种方式。考虑下边的例子：

```haskell
ghci>[(*2)] <*> [1,2,3,4]
[2,4,6,8]
ghci>[length] <*> ["ss", "tt", "bar"]
[2,2,3]
```
这里的容器类型（构造函数）是`[]`本身，所以其中的映射函数 `a->b` 必须放置在 `[]`中，对应的**applicative**参数分别是`Int`和`[Char]`。考虑如下更复杂一点的情形： 

``` haskell
ghci>[(^2), sqrt]  <*> [1..4]
[1.0,4.0,9.0,16.0,1.0,1.4142135623730951,1.7320508075688772,2.0]
```
这里的`<*>`操作结果为对于左边的每一个函数，依次作用于右边的每一个元素，并且返回结果的list。自然左边参数的函数类型必须是相同的;根据以上行为可见，list 的 Applicative定义其实为：
``` haskell
instance Applicative [] where
    pure x = [x]
    gs <*> xs = [g x | g <- gs, x <- xs]
```
其`<*>`函数是通过**list comprehension**来完成的。

另外一种实现是分别取左右（相对于操作符 `<*>` 函数的中缀表达式写法）的对应函数和参数，将所得的运算结果放置于结果list中；即ZipWith:
``` haskell
newtype ZipList a = ZipList {getZipList :: [a])

instance Applicative ZipList where
    pure x = ZipList (repeat x)
    ZipList fs <*> ZipList xs = ZipList (zipWith (\f x -> f x) fs xs)
```

下边是一个ZipList的例子：

``` haskell
ghci>getZipList $ ZipList [(^2), sqrt, (+10), (/2)] <*> ZipList [2..10] 
[4.0,1.7320508075688772,14.0,2.5]
```
这里，操作的结果是依次应用于左边的每一个函数于右边的每一个List元素，生成结果的`ZipList`.

### <$> 操作符

为了简化代码并且提高可读性，Applicative定义了`<$>`操作符，类似于基本的`($)`函数，且有：
``` haskell
f <$> a = fmap f a
pure f <*> x = fmap f x = f <$> x

-- we can further write
g :: (a->b->c)
f g <*> f a <*> f b <*> f c = pure g <*> f a <*> f b <*> f c = g <$> f a <$> f b <*> f c

--example
ghci>let f a b c d = 2 * a + 3 * b + 4 * c + 5 * d
ghci>:type f
f :: Num a => a -> a -> a -> a -> a
ghci>f <$> Just 1 <*> Just 2 <*> Just 3 <*> Just 4
Just 40
ghci>Just (f 1 2 3 4)
Just 40
```
上述的编程风格又被成为 **Applicative Style** .

### Applicative 定律

Applicate的实例类型必须满足如下定律：
``` haskell
pure id <*> v = v                               --Identity
pure (.) <*> u <*> v <*> w = u <*> (v <*> w)    --Composition
pure f <*> pure x = pure (f x)                  --Homomorphism
u <*> pure y = pure ($ y) <*> u                 --Interchange
```
对于Maybe类型，可以做如下验证：
- Identity
```haskell
ghci>pure id <*> Just 1
Just 1
ghci>Just 1
Just 1
```
- composition
```haskell
ghci>(.) (*2) (+3) 2
10
ghci>pure (.) <*> Just (*2) <*> Just (+3) <*> Just 2
Just 10
ci>Just (*2) <*> (Just (+3) <*> Just 2)
Just 10
```
- Homomorphism
``` haskell
ci>Just (*2) <*> Just 2
Just 4
ghci>Just ((*2) 2)
Just 4
```

- Interchange
```haskell
ghci>Just (*2) <*> pure 2
Just 4
ghci>pure ($ 2) <*> Just (*2)
Just 4
```

### IO Monad and Applicative

所有的Monad都满足Applicative的要求；其实Monad对结构化的要求比Applicative的要高。对于IO Monad，以下是其实现：
``` haskell
instance Applicative IO where
    pure = return
    a <*> b = do
        f <- a
        x <- b
        return (f x)
```

对于如下的do风格程序：
``` haskell
greeting = do
    firstName <- getLine
    LastName <- getLine
    putStrLn $ "hello" ++ firstName ++ lastName
```
可以用Applicative风格更优雅地写作：
``` haskell
greeting = do
    name <- (++) ($) getLine <*> getLine
    putStrLn $ "hello" ++ name
```

可以看到，如果将上边的IO类型换做其它的Monad也是照样成立的。可见所有的Monad类其实也满足Applicative，但是由于Monad类型的出现早于Applicative，因此Haskell自带的定义中没有指明上述的约束关系。

### Applicative 辅助函数

Aplicative定义了如下一些辅助函数用于简化代码书写：
``` haskell
liftA :: Applicative f => (a->b) -> f a -> f b
liftA f a = pure f <*> a = f <$> a

liftA2 :: Applicative f => (a -> b -> c ) -> f a -> f b -> f c
liftA2 f a b = f <$> a <*> b

liftA3 :: Applicative f => (a -> b -> c -> d) -> f a -> f b -> f c -> f d
liftA3 f a b c = f <$> a <*> b <*> c
```

## Functor/Applicative Functor/Monad

在Monad中，Haskell定义了`ap`函数, 如果参照`<*>`的定义：
``` haskell
ghci>:info ap
ap :: Monad m => m (a -> b) -> m a -> m b
    -- Defined in Control.Monad

ghci>:type (<*>)
(<*>) :: Applicative f => f (a -> b) -> f a -> f b
```
可以看出，如果将m替换为f，那么二者的定义是一致的。其实Monad是一种比Applicative更强的约束,同样地，`liftM`, `liftM2`....和fmap/<*>也很相似。二者的关系和相关的提议可参考[这里](http://www.haskell.org/haskellwiki/Functor-Applicative-Monad_Proposal)。


## 参考资料
1. [learnyouahaskell on functors and applicative functors](http://learnyouahaskell.com/functors-applicative-functors-and-monoids)
2. [Applicative Functors in Haskell](http://wiki.ifs.hsr.ch/SemProgAnTr/files/ApplicativeFunctorsInHaskell.pdf)
3. [Functors and Applicative Functors](http://db.inf.uni-tuebingen.de/files/weijers/AFP1112/lecture7.pdf)
4. [Functor-Applicative-Monad Proposal](http://www.haskell.org/haskellwiki/Functor-Applicative-Monad_Proposal)

