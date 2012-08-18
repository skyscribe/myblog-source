---
layout: post
title: "Parallel programming in Haskell"
date: 2012-08-02 20:55
comments: true
categories: [haskell, concurrency, performance, tips, 学习笔记]
---

Parallel和Concurrency的目标是一致的，然后Parallel更强调在多个物理并发处理单元（至少从OS之上的角度看如此）存在的情况下，如何最大限度地利用现有的CPU资源提高程序的性能。传统的过程式编程思维范式中，所有的操作都是顺行串行的，多核并发处理往往意味着需要对代码做大幅度的修改；而Haskell的并行编程则因为其**Lazy Evaluation**特性而变得简单许多 - 基于现有的代码做一些相对细微的改动就可以使得某些操作并行起来。同样由于这一Lazy特性和表达式赋值的灵活性，很多隐晦的问题也很容易随之而生。Haskell通过提供Strategy抽象将赋值策略和实际算法隔离开来，从而灵活的解决了Lazy带来的副作用。

<!--more-->
## 如何启用并行执行

*如下方法仅使用于GHC编译器*

GHC采用运行时指定的方式来引导运行时系统将程序分布在多个物理核心上执行。GHC在启动程序代码的时候，会先扫描命令行传入参数中关于运行期控制的参数，解析其选项值，然后将其从arglist中删除，即这些控制参数对程序本身而言是透明不可见的。

GHC运行时通过识别`+RTS`和`-RTS`来解析运行时参数，其中间的部分会被认为是控制GHC运行时的选项。对于并发而言，我们需要关注的是`-Nx`参数，而这里的**x**需要设置为CPU的核心数目。在Linux系统上，可以用如下命令获取CPU线程数目：
```bash
cat /proc/cpuinfo  | grep "^processor" | wc -l
```

当然也可以用如下的Haskell工具函数：
```haskell
import GHC.Conc (numCapabilities)
import System.Environment (getArgs)

main = do
    args <- getArgs
    putStrLn $ "command line arguments: " ++ show args
    putStrLn $ "number of cores: " ++ show numCapabilities
```

首先编译代码的时候需要加入`-threaded`的选项告知编译器支持并发,然后需要在程序运行的时候传入`-N`:
```bash
ghc -c NumCapabilities.hs
ghc -threaded -o NumCapabilities NumCapabilities.o 
./NumCapabilites +RTS -N4 -RTS
```

这个例子还可以表明RTS参数不会传入程序的getArgs中;此无如果传入的N个数超出物理核心数，GHC会提示需要打开`-rtsopts`编译选项，否则运行时拒绝执行程序代码。

## 通过小幅修改代码实现并行

对于CPU密集型的运算，一种通用的并行思路是将需要解决的问题划分为各个不相关的子部分，然后对每个子部分做分别处理，最后再归拢各个子部分的处理结果，即所谓的**分治法**，但是这样做同时意味着必须对实现代码作出修改 - 至少在其它非函数式语言环境中需要这么做。Haskell则提供了另外一些一个比较简单的思路：对已有的代码做一些简单转换，然后使得他们可以被并行执行。

### Normal Form 和 Head Normal Form

在Haskell中，Normal Form即为普通的表达式赋值规则-对应的表达式会被完全赋值，而Head Normal Form 则仅仅执行到某部分的最外层构造函数就停止赋值。还有另外一种所谓Weak Head Normal Form的方式，其对数据类型的规则和Head Normal Form是一样的，仅仅在函数处理上有所[不同](Further discussion can be found on Stackoverflow: http://stackoverflow.com/questions/6872898/haskell-what-is-weak-head-normal-form).

### 分治法的例子 - QuickSort

下边是一个简单的分治法例子 - 快速排序：
``` haskell
sort :: (Ord a) => [a] -> [a]
sort (x:xs) = lesser ++ x:greater
    where lesser  = sort [y | y <- xs, y <  x]
              greater = sort [y | y <- xs, y >= x]
              sort _ = []
```

对于这个朴素的例子，可以通过一些细微的变化使其并行起来：
``` haskell
import Control.Parallel (par, pseq)

parSort :: (Ord a) => [a] -> [a]
parSort (x:xs)    = force greater `par` (force lesser `pseq`
                         (lesser ++ x:greater))
             where lesser  = parSort [y | y <- xs, y <  x]
                   greater = parSort [y | y <- xs, y >= x]
parSort _         = []
```

#### 新函数

这里的不同之处是加入了`force`,`par`和`pseq`的调用:
- `par`函数会先赋值其左边表达式到WHNF，然后返回其右侧的部分。对于`par`而言，其操作可以和其它正在进行的赋值并行进行。  
- `pseq`函数会保证其左侧的表达式必定先于右侧表达式被赋值，并且默认规则是按照WHNF   
- `force`函数的定义如下：   
```haskell
force :: [a] -> ()
force xs = go xs `pseq` ()
    where go (_:xs) = go xs
              go [] = 1
```
    这里的force函数确保list类型的每一个元素都被赋值。如果去掉这里的force,那么算法本身会和顺序的方案一样，因为`pseq`仅仅要求左侧表达式按照WHNF来赋值，而对于list类型而言，只要第一个元素（HEAD）被赋值，那么这个左侧的赋值操作即算完毕，加入`force`就保证了做最后返回的部分，`greater`和`lesser`部分均已赋值完毕。


#### 性能问题

Haskell的线程代价比大部分其它语言的线程代价都要小，但是并发意味着对共享内存的访问和控制，这些开销并不是任何时候都可以忽略的。对上述程序的性能做剖析会发现，其实上述算法对每一个运算都尽量来并发直到list本身只剩下一个元素，那么多线程带来的并发开销会大于带来的好处。一种这种的方案是检测递归的深度，然后到某种程度停止并发处理，转回线性处理：

```haskell
parSort2 :: (Ord a) => Int -> [a] -> [a]
parSort2 d list@(x:xs)
  | d <= 0     = sort list
  | otherwise = force greater `par` (force lesser `pseq`
                         (lesser ++ x:greater))
      where lesser      = parSort2 d' [y | y <- xs, y <  x]
            greater     = parSort2 d' [y | y <- xs, y >= x]
            d' = d - 1          
            
parSort2 _ _              = []
```

#### GC的问题

GHC的GC还是采用单线成的方式，因而在GC工作的时候，其它线程的处理都会被暂停执行，这个问题在某些情况下也是需要注意的。

## 策略Strategy

采用分治法处理并发问题的时候，不管采用何种语言，都会遇到如下的问题：  
- 算法处理本身很容易被并发控制的细节所淹没 - 尤其算法逻辑变得复杂之后   
- 并发处理单元的粒度控制变得富有挑战 - 太大的粒度浪费CPU资源，而过小的粒度则会代理更多并发控制本身的开销  

### ParallelMap 的例子和问题  

回到上边的例子，为了将传统的顺序程序改为并行，我们必须在代码中小心的插入`pseq`/`par`/`force`来指明整个并行方式需要如何赋值运算，甚至对于`list`类型，还需通过自定义的`force`函数来强制赋值每一个元素以保证算法的正确性,这一方式看起来无疑是非常繁琐甚至重复的。再考虑`map`这一很重要的函数，对于并发控制，同样需要定义一个`paralleMap`才能放在代码里边用:

``` haskell
import Control.Parallel (par)

parallelMap :: (a -> b) -> [a] -> [b]
parallelMap f (x:xs) = let r = f x
                       in r `par` r : parallelMap f xs
parallelMap _ _      = []
```

即使对于这个版本的实现，如果b类型本身是一个list，那么这个算法很可能还是不能真正并行起来，因为`list`类型的WHNF仅仅运算第一个元素；我们可能不得不新实现一个针对特殊类型的（`list`)的版本，甚至于对很多不同类型的`b`都可能需要一些特殊的处理。


一种想法是，我们可以引入一个指定某个类型的赋值规则的**函数参数**来确定某个类型的赋值方式，譬如：
``` haskell
forceListAndElts :: ((a->())-> [a] -> ()
forceListAndElts forceElt (x:xs) = forceElt x `seq` forceListAndElts forceElt xs
forceListAndElts _ _ = ()
```

这里的函数强制list的每一个元素都按照对应元素类型的`forceElt`函数赋值到对应的形式（WHNF等）。将上述想法扩展泛化就回得到**Strategies**：

### Strategies

Haskell通过库的方式提供Strategies的支持：
``` haskell
ghc>:m +Control.Parallel.Strategies
ghc>:info Strategy 
type Strategy a = a -> Eval a
  -- Defined in `Control.Parallel.Strategies'
ghc>:info Eval 
newtype Eval a
  = Control.Parallel.Strategies.Eval (GHC.Prim.State#
                                          GHC.Prim.RealWorld
                        -> (# GHC.Prim.State# GHC.Prim.RealWorld, a #))
            -- Defined in `Control.Parallel.Strategiestegies'
instance Monad Eval -- Defined in `Control.Parallel.Strategies'
instance Functor Eval -- Defined in `Control.Parallel.Strategies'
```
`Strategy`是一个`typeclass`,对每一个类型a, `Eval`构造出一个具体的Strategy，而`Eval`本身则是个`newtype`,并且是个Monad/Functor实例。此外，Strategy库还定义了如下Strategy:
``` haskell
ghc>:info rwhnf 
rwhnf :: Strategy a -- Defined in   `Control.Parallel.Strategies'

class NFData a where
    rnf :: a -> ()
    rnf = rwhnf

instance [safe] NFData a => NFData [a]
instance [safe] NFData a => NFData (Maybe a)
instance [safe] NFData Integer
instance [safe] NFData Int
instance [safe] NFData Float
-- more basic types ... 
instance [safe] (NFData a, NFData b) => NFData (Either a b)
-- tuple
instance [safe] (NFData a1, NFData a2, NFData a3, NFData a4,
                 NFData a5, NFData a6, NFData a7, NFData a8) =>
             NFData (a1, a2, a3, a4, a5, a6, a7, a8)

-- more follows ....
```
Typeclass`NFData`抽象了所有的Strategy并且提供了`rnf`和`rwhnf`并且提供了大部分基本类型的实现，譬如常见的`Maybe`类型：
```haskell
instance NFData a => NFData (Maybe a) where
    rnf (Nothing) = ()
    rnf (Just x) = rnf x
```
对于自定义类型，我们就可以自己依照实现自己的`rnf`方法。对于自定义类型，`rnf`必须赋值到每一个构造函数的每一个字段。

## 策略和算法的解耦合

根据基本的Strategy,我们可以组合出更丰富的赋值方式，比如：
```haskell
parList :: Strategy a -> Strategy [a]
parList strat []     = ()
parList strat (x:xs) = strat x `par` (parList strat xs)

parMap :: Strategy b -> (a -> b) -> [a] -> [b]
parMap strat f xs = map f xs `using` parList strat
```

上述`parMap`的实现中，左边的算法部分仍然是相同的`map f xs`实现，而`using`函数则将左侧的实际算法和右侧的`Strategy`结合起来了：
``` haskell
using :: a -> Strategy a -> a
using x s = s x `pseq` x
```

### MapReduce 的例子
一个简化版本的MapReduce例子如下：
``` haskell
mapReduce
    :: Strategy b    -- evaluation strategy for mapping
    -> (a -> b)      -- map function
    -> Strategy c    -- evaluation strategy for reduction
    -> ([b] -> c)    -- reduce function
    -> [a]           -- list to map over
    -> c

mapReduce mapStrat mapFunc reduceStrat reduceFunc input =
    mapResult `pseq` reduceResult
      where mapResult  = parMap mapStrat mapFunc input
          reduceResult = reduceFunc mapResult `using` reduceStrat
```

Haskell通过引入Strategy的方式分离算法和并发控制，从而比较优雅的部分解决了这个问题（当然更好的解决需要STM的参与）。

## 参考  
1. [RealWorld Haskell - chapter 24](http://book.realworldhaskell.org/read/concurrent-and-multicore-programming.html)  
2. [Haskell parrale reading](http://www.haskell.org/haskellwiki/Parallel/Reading)  
3. [Algorithm + Strategy = Parallelism](http://www.macs.hw.ac.uk/~dsg/gph/papers/html/Strategies/strategies.html)

