---
layout: post
title: "Concurrency with Haskell"
date: 2012-07-23 19:49
comments: true
categories: [haskell, 学习笔记, concurrency]
---

随着基于CPU频率的摩尔定律的失效，现代的计算机体系都采用多核的方式提高处理能力，传统的编程思维和模式在多核时代则遭遇越来越多的问题；而函数式编程则在很大程度上提供了完全不同但是更为优雅的思路。作为纯函数式编程语言，Haskell的并发编程则和传统的过程式语言有着明显的不同。

<!--more-->

## 并发(concurrency)和并行(parralelism)

在多核编程中，这是两个经常被误解的概念，两者同样用于**同时**执行一些任务；**并发**强调多个自子任务在同一个时间段内发生，其实际可能是在单个CPU上运行，比如某个任务在等待IO的同时可以暂时让度CPU，另外一个任务先执行操作然后第一个任务的IO完成的时候再切换回来，这样在宏观上看，两个任务是*似乎同时*进行的；而**并行**一般是强调单个的任务和其它单任务**同时进行**。

并行的程序肯定需要多个物理的CPU，至少从应用程序角度看到的是两个独立运行的CPU（譬如超线程技术或者Sun的CMT）；而并发程序未必需要多个物理核，例如传统语言中常见的事件驱动库或者多线程调度可能在单个物理核上运行。

## 两种Concurrency方式

Haskell提供了两种Concurrency模式，一个是传统的Thread/condition/semaphore方式，另外一种为STM方式。

### Thread 方式

Haskell的Thread方式和传统的变成语言或者库有显著的不同；其定义在`Control.Concurrent`中提供。由于Thread本身是有副作用的，hanskell通过封装**IO Monad**的方式来提供Thread,即一个thread为一个**IO action**,要使用thread则可以调用`forkIO`来执行一些任务。

``` haskell
ghc>:m +Control.Concurrent
ghc>:info forkIO
forkIO :: IO () -> IO ThreadId -- Defined in `GHC.Conc.Sync'

ghc>:m +System.Directory 
ghc>forkIO (writeFile "newFile" "may not be written yet!" ) >> doesFileExist "newFile"
Loading package bytestring-0.9.2.1 ... linking ... done.
Loading package unix-2.5.1.0 ... linking ... done.
Loading package old-locale-1.0.0.4 ... linking ... done.
Loading package old-time-1.1.0.0 ... linking ... done.
Loading package filepath-1.3.0.0 ... linking ... done.
Loading package directory-1.1.0.2 ... linking ... done.
True
```

需要注意的是，由于新线程的执行顺序是不确定的，因此上述例子中的程序返回结果可能不同。因为haskell中的变量全部是不可变的，因此在forkIO中传递变量是安全的，这个可以作为传递参数的一种很方便的形式，譬如下边的例子：
``` haskell
import Control.Concurrent(forkIO)
import Control.Monad(forever)

acceptConnections :: Config -> Socket -> IO ()
acceptConnections config socket
    = forever ( do  
            conn <- accept socket ;
            forkIO (serviceConn config conn) 
            )

accept :: Socket -> IO Connection
type Connection = (Handle, SockAddr)
```
这里的`serviceConn`的两个参数都是从当前线程传递到新创建的线程。

### 线程通信和基本交互

GHC中定义了MVar来方便不同线程之间的通信，并定义有`putMVar`和`takeMVar`, 同样它们都是**IO action**:

``` haskell
ghc>:info MVar 
data MVar a = GHC.MVar.MVar (GHC.Prim.MVar# GHC.Prim.RealWorld a)
-- Defined in `GHC.MVar'
instance Eq (MVar a) -- Defined in `GHCC.MVar'
ghc>:info putMVar 
putMVar :: MVar a -> a -> IO () -- Defined    in `GHC.MVar'
ghc>:info takeMVar 
takeMVar :: MVar a -> IO a -- Definedd in `GHC.MVar'
ghc>:info newEmptyMVar 
newEmptyMVar :: IO (MVar a) --  Defined in `GHC.MVar'
ghc>:info newMVar 
newMVar :: a -> IO (MVar a) -MVar- Defined in `GHC.MVar'

```

这里的**MVar**变量状态可能为空或者满。`takeMVar`动作会先检查MVar状态是否为空，为空则阻塞当前的线程知道满为止；`putMVar`则是空就写入新的状态量，满则等待挂起当前线程。

两个**new**操作各用于创建一个新的空/满MVar.

和传统的线程库类比，可以发现其实MVar可以实现：
1. 从一个线程向另外一个线程发送通知消息
2. 对共享数据进行互斥操作，类似于mutex

下边是一个更复杂的例子，用于webserver统计所有的子连接个数 - 控制线程可以做更多有意义的控制，比如在负载满的时候停止创建新的线程等：
``` haskell
cceptConnections :: Config -> Socket -> IO ()
acceptConnections config socket
= do {  count <- newEmptyMVar ;
        putMVar count 0 ;
        forever (do {   conn <- accept socket ;
                        forkIO (do { inc count ;
                                     serviceConn config conn ;
                                     dec count})
                    }) }

inc,dec :: MVar Int -> IO ()
inc count = do { v <- takeMVar count; putMVar count (v+1) }
dec count = do { v <- takeMVar count; putMVar count (v-1) }
```

### Channel

对于简单的线程通信和交互,MVar就可以满足大部分需求；对于复杂的通信，Haskell还提供了**Channel**支持：

``` haskell
c>:info Chan 
data Chan a
= Control.Concurrent.Chan.Chan (MVar
                                  (Control.Concurrent.Chan.Stream a))
                             (MVar (Control.Concurrent.Chan.Stream a))

-- Defined in `Control.Concurrent.Chan'
instance Eq (Chan a) -- Defineded in `Control.Concurrent.Chan'
ghc>:type readChan 
readChan :: Chan a -> IO a
ghc>:type writeChan 
writeChan :: Chan a -> a -> IO ()
ghc>:type newChan 
newChan :: IO (Chan a)
```

Channel提供了一种单向的线程通信通路，可以实现CSP编程。`readChan`在没有数据的时候，将一直阻塞直到有新的数据到Channel中，而`writeChan`则永不阻塞，写入一个新的值并且立即返回。这一特性也表明，如果写的速度快于读取的速度，则Channel可以会一直占用更多的资源。

## 共享状态的并发编程仍然是困难重重

只要是共享状态信息，那么dead-lock/starvation/race condition这些传统的问题就不可避免。幸运的是，新的STM方式可以在很大程度上缓解这些问题。

### STM 方式

STM是一种相对比较新的并发编程模型，其全称为Software Transaction Memory，其基本思想类似于DB操作中的Transaction Procedure,对于给定内存的操作要么全部完成，要么完全回到操作之前的初始状态。对于某一个给定的内存块，一个线程进入操作这个内存块进行操作的时候，另外一个线程看不到其它进程对这个内存块的操作，如果操作失败，那么会完全回退到进入之前的状态。

STM的定义在`Control.Concurrent.STM`中：
```haskell
newtype STM a
  = GHC.Conc.Sync.STM (GHC.Prim.State# GHC.Prim.RealWorld
                         -> (# GHC.Prim.State# GHC.Prim.RealWorld, a #))
               -- Defined in `GHC.Conc.Sync'

instance Monad STM -- Definedd in `GHC.Conc.Sync'
instance Functor STM -- Defined in `GHC.Conc.Sync'

ghc>:info TVar

data TVar a
  = GHC.Conc.Sync.TVar (GHC.Prim.TVar# GHC.Prim.RealWorld a)
    -- Defined in `GHC.Conc.Sync'

instance Eq (TVar a) -- Definedned in `GHC.Conc.Sync'
```

对应的TVar操作：
``` haskell
ghc>:t newTVar
newTVar :: a -> STM (TVar a)
ghc>:t readTVar
readTVar :: TVar a -> STM a
ghc>:t writeTVar 
writeTVar :: TVar a -> a -> STM ()
```

这里的STM是一个Monad，用于约束所有的操作必须在STM的保护之内，任何操作不能逃离STM之外。任何基于STM的operation可以通过>>=, >>, return等方式组合为新的monad actions，即transaction；整个transaction对于TVar的访问是原子的。

### 一个具体的例子

下边这个例子来自于[wikipedia](http://en.wikipedia.org/wiki/Concurrent_Haskell):

``` haskell
type Account = TVar Integer

transfer :: Integer -> Account -> Account -> STM ()
transfer amount from to = do
   fromVal <- readTVar from
   if (fromVal - amount) > 0
     then do
        debit amount from
        credit amount to
     else retry

credit :: Integer -> Account -> STM ()
credit amount account = do
     current <- readTVar account
     writeTVar account (current + amount)
          
debit :: Integer -> Account -> STM ()
debit amount account = do
    current <- readTVar account
    writeTVar account (current - amount)
```
在`transfer`函数中，我们先检查了对应的余额是否重组，如果是则继续完成转账，否则就`retry`，retry的实现保证只有对应的变量发生变化时候才重试，从而大大提高了效率。
```haskell
ghc>:t retry
retry::STM a
```

这里的每一个操作返回类型都是**STM**,从而保证这些操作都是原子性的。一个特殊的函数`atomically`则用于从STM返回一个IO：

```haskell
ghc>:t atomically 
atomically :: STM a -> IO a
```

下边是一个调用上述实现的例子：
``` haskell
module Main where
 
import Control.Concurrent (forkIO)
import Control.Concurrent.STM
import Control.Monad (forever)
import System.Exit (exitSuccess)
 
main = do
    bob <- newAccount 10000
    jill <- newAccount 4000
    repeatIO 2000 $ forkIO $ atomically $ transfer 1 bob jill
    forever $ do
        bobBalance <- atomically $ readTVar bob
        jillBalance <- atomically $ readTVar jill
        putStrLn ("Bob's balance: " ++ show bobBalance ++ ", Jill's balance: " ++ show jillBalance)
            if bobBalance == 8000
                then exitSuccess
                else putStrLn "Trying again."
                         
repeatIO :: Integer -> IO a -> IO a
repeatIO 1 m = m
repeatIO n m = m >> repeatIO (n - 1) m

newAccount :: Integer -> IO Account
newAccount amount = newTVarIO amount

--other definitions in above code snippets
```



## 参考资料
1. [GHC concurrency](http://www.haskell.org/haskellwiki/GHC/Concurrency)  
2. [Haskell parallel reading](http://www.haskell.org/haskellwiki/Parallel/Reading)  
3. [Real world haskell, ch24](http://book.realworldhaskell.org/read/concurrent-and-multicore-programming.html)  
4. [Concurrent Haskell wiki](http://en.wikipedia.org/wiki/Concurrent_Haskell)   
