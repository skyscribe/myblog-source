---
layout: post
title: "STM in Haskell"
date: 2012-08-12 09:54
comments: true
categories: [haskell, 学习笔记, concurrency]
---

传统的并发变成模型通过Mutex/Conditional Variable/Semaphore的设施来控制对共享资源的访问控制，但是这一经典模型使得编写**正确高效**的并发程序变得异常困难：  
  > 1. 遗漏合适的锁保护导致的**race condition**   
  > 2. 锁使用不当导致的死锁**deadlock**  
  > 3. 异常未合适处理导致的程序崩溃   
  > 4. 条件变量通知操作遗漏导致的等待处理没有被合适的唤醒  
  > 5. 锁粒度控制不当造成性能下降  

STM(**Software Transaction Memory**)提供了一种简洁而又安全的方式来尝试完美地解决上述大部分问题。

<!--more-->

## 基本思想

STM的基本设计规则如下：   
* 对共享资源的访问进行控制从而使不同线程的操作相互隔离  
* 规则约束：   
  > - 如果没有其它线程访问共享数据，那么当前线程对数据的修改同时对其它线程可见   
  > - 反之，当前线程的操作将被完全丢弃并自动重启   

这里的**要么全做要么什么也不做**的方式保证了共享数据访问操作的原子性，和数据库中的Transaction很相像。

## Haskell定义

### 模块和类型

GHC的支持在`Control.Concurrent.STM`中，并提供了`TVar`(相对于`MVar`)：
```haskell
newtype STM a 
    = GHC.Conc.Sync.STM (GHC.Prim.State# GHC.Prim.RealWorld
                         -> (# GHC.Prim.State# GHC.Prim.RealWorld, a #))

-- STM is an instance of Monad and Functor
instance Monad STM;
instance Functor STM;

--TVar type wraps a data of abstract type a
data TVar a;

--creation functions
newTVar :: a -> STM (TVar a)

--readTVar
readTVar::Tvar a -> STM a
--writeTVar
writeTVar::TVar a -> a -> STM ()

-- atomically provide wrapper to convert STM types to plain IO type
atomically :: STM a -> IO a
```
这里`STM`提供了一个STM类型的抽象，并且定义其自身为`Monad`和`Functor`的实例。`TVar`则提供了对数据类型的封装和`Monadic`操作。

### 一个简单的例子

下边是一个基本的例子：
{% include_code [stm_example.hs] stm_example.hs %}

这里创建了一个初始为0的共享变量，并且启动三个线程分别做不同的操作：  
- 第一个线程每隔20毫秒打印当前的变量   
- 第二个线程每隔50毫秒将变量当前值倍2  
- 第三个线程每隔25毫秒取出当前变量的值并将其减1  
- 主线程等待800毫秒（每个子线程执行500毫秒）打印共享变量的数值  

这个例子可以看出STM使代码变得相当简洁优雅。  

## Retry

Haskell的STM API提供了retry机制，当某个transaction不能成功的时候，retry可以重新启动整个Transaction，当然这个Transaction只有当其它线程对共享数据做修改之后才会重新启动，从而避免性能损失。
下边是一个例子：
```haskell
transfer :: Gold -> Balance -> Balance -> STM ()

transfer qty fromBal toBal = do
  fromQty <- readTVar fromBal
  when (qty > fromQty) $
        retry
  writeTVar fromBal (fromQty - qty)
  readTVar toBal >>= writeTVar toBal . (qty +)
```
## 参考  
1. [STM in Real World Haskell, chapter 28](http://book.realworldhaskell.org/read/software-transactional-memory.html)    
2. [STM:Wikipedia](http://en.wikipedia.org/wiki/Software_transactional_memory)   
3. [Haskell wiki on STM](http://www.haskell.org/haskellwiki/Software_transactional_memory)   
