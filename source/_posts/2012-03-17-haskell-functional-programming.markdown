---
layout: post
title: "haskell函数式编程"
date: 2012-03-17 20:49
comments: true
categories: [haskell, functional]
---

作为纯函数式语言，haskell的主要特征之一即是提供丰富的函数式变成设施，包括 recursion / composition / lambda / partial & currying 等。Haskell本身的强类型约束和延迟赋值，使得其函数式风格明显区别于流行的 ruby/python 等其它语言。

<!--more-->
## list 操作函数
List 是 haskell 内建类型里边的最基本类型之一，也是函数式变成风格的基础。其基本操作和 scheme 中的基本类似，基础操作有：

- head/last 返回第一个/最后一个元素   
- init/tail 返回除了最后一个/第一个 之外的所有元素
- map 对于每一个元素，调用给定的单参数函数，返回函数操作结果构成的List
- any 遍历List中的每一个元素，如果其中一个使得给定的函数返回True，则返回True；反之返回False
- filter 将所有能使给定函数返回结果为True的元素留下，得到一个新List

以上操作可能回遍历List中的每一个元素，所以某些情况，不一定效率就高。

## Partial function and currying

任何函数在Haskell中本质上仅仅绑定一个参数，如果在声明了可以绑定多个参数的函数后边提供少于期望个数的参数后，便可以得到一个新的函数，新函数的参数个数等于原函数的参数数减去已经提供的参数个数。如果提供的参数个数和期望的参数个数相同，则对应的就是一个新的函数调用；否则，我们得到了一个 partial function, 其中未指定的参数可以在随后调用中指定。例如：

``` haskell
Prelude> :type foldl
foldl :: (a -> b -> a) -> a -> [b] -> a
Prelude> :type foldl (+)
foldl (+) :: Num b => b -> [b] -> b
Prelude> :type foldl (+) 2
foldl (+) 2 :: Num b => [b] -> b
```
上边的例子中，`foldl`函数本身可接受一个cumulate函数，一个cumulate变量，和一个List。通过一次提供一个和两个参数，分别得到了2个 partial function, 并且随着新提供参数的类型，2 个 partial function 的类型也被自动推倒出来。

由于Haskell的**lazy evaluation**特征，partial function中的中间参数只有在函数被实际调用的时候才会赋值。

## folds or loops

Haskell中的循环其实是通过递归(recursion)来完成的，配合pattern matching和condition可以完成和其它语言中的loop同样的工作。加上 tail recursion optimization (**TVO**) 和 lazy evaluation, haskell通过函数式的思维描述命令式语言中的循环功能。

对于一些很常见的从一个链表中计算一个结果的操作，haskell提供了一些fold函数来简化代码，不再需要通过手工编写的 recursion/pattern matching来完成。如下的代码完成给定字符串转换为对应的**Int**数（仅仅处理正整数）：

``` haskell
type ErrorMessage = String
asInt_either :: String -> Either ErrorMessage Int
asInt_either "" = Left "None string can't be converted!"
asInt_either ('-':_) = Left "negates not supported!"

asInt_either xs = foldl calc (Right 0) xs where
    calc result c | isDigit c = 
            case result of 
                Left errMsg -> Left errMsg
                Right num   -> 
                    let result = num * 10 + (digitToInt c)
                    in if result < 0
                        then Left "overflow"
                        else Right result 
    calc result c | otherwise = Left "invalid character"

isDigit c | ord c < ord '0' = False
          | ord c > ord '9' = False

```

- foldl 从左往右，用给定的函数作用于一个状态参数和List的每一个参数，将得到的状态作为下一次计算的状态参数。foldl 在实际运用中很少直接用，因为其本身需要缓存参数的中间函数栈，对于比较长的List可能造成 **stack overflow ** ; 这是由于 lazy evaluation 造成的  

- foldr 从右往做运算，每次从List中取出一个元素作为给定函数的第一个参数，第二个参数为右侧已经计算的foldr，当作用于最后一个元素时候，返回的是初始状态参数。日常使用中尽可能用 foldr 替代 foldl    

实际应用的时候，需要遵循：  
- 如果某个操作可以通过 folds函数和其它一些函数组合来完成，则尽量避免用手工的 recursion 和 pattern matching.  
- 尽量采用 foldr

## lambda or local function and composition

lambda 在 haskell 中用的并不是太多，因为其会造成程序可读性下降，而Haskell中可以通过 `let .. in` 或者 `where`的方式很轻松的定义局部函数。此外局部函数可以用一个描述其目的的名字来更好的帮助理解调用点的逻辑。例如：

``` haskell
func :: [Integer] -> [Integer]
func = map (\a -> (a^(a-1) + a)) 

-- equals to below func
func = map calc where calc a = a ^ (a-1) + a
```

函数可以相互组合，默认的方式是从左到右从而生成高阶函数，`.`可以用于组合函数使得先调用右侧函数，再作用于左侧。即:

``` haskell
func1 func2 func3 param = ((func1 func2) func3) param
func1 . func2 . func3 param = func1 ( func2 ( func3 param) )
```

## sections, as pattern and lazy evaluation

Section 用于简化函数的组合，使得函数调用可以用中缀表达式的方法来书写，以增强代码可读性。譬如：

``` haskell
(1+) 2j
map (*3) [23,36]
(`elem` ['a'..'z'] 'f'
isAny needle haystack = any (need `isInfixOf`) haystack
```

As-pattern 用于提高代码可读性，并减少新list的copy开销，`@`之后的部分将绑定到之前的一个变量之上，之后可以直接引用此变量而不需要创建新的List,例如：
``` haskell
suffixes :: [a] -> [[a]]
suffixes xs@(_:xs') = xs : suffixes xs'
suffixes _ = []
```

`seq`可以用于解决lazy-evaluation导致某些部分由于没有被调用而没有赋值的情况。`seq`的应用需要注意：

1. `seq`表达式必须表达式中第一个被赋值的，例如：   
``` haskell
forceEv x y = x `seq` someFunc y
chained x y z = x `seq` y `seq` someFunction z
```
2. `seq`在遇到一个Constructor的时候即停止，对于ADT （Algegric Data Type), Constructor之后的东西将不会被预先赋值。  
3. `seq`在有可能的时候需要尽量少用，多思考 lazy evaluation。  

