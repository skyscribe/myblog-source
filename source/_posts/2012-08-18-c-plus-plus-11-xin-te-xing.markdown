---
layout: post
title: "c++11 新语言特性-1"
date: 2012-08-18 10:03
comments: true
categories: [cpp, clang, llvm, tips, cpp11, 学习笔记]
---

**C++11**(C++0x)[定稿](http://herbsutter.com/2011/10/10/iso-c11-published/)已经满一年，主要的编译器这次跟进的速度也相当快，其中支持最好的要属最近声名雀起的[llvm](http://llvm.org/);作为一个历时8年之久的ISO标准，其诞生过程虽然过程很曲折，但是新标准对C++的改进和生产效率的提高无疑是大有益处的。

<!--more-->

新标准增加了好多语言特性来提高编码本身的效率，这也可以看作是对其它新挑战者快速进化带来的压力的应对：

## 初始化列表 Initializer list
----------------------------------

在C++03标准中，我们可以用初始化列表的方式来快速构造结构体类型对象或者简单的类型数据，但是这种便利到**non-POD**类型就无能为力了；而实际使用中，大多C++对象本身是可能带有虚函数或者包含有non-POD的子对象（尤其是STL容器对象），导致初始化列表的好处大打折扣。而在C++11中，我们就可以初始化非POD类型数据了:

{% gist 3383906 initializer-list.cpp %}

这里的构造函数可以用`initializer_list<T>`来初始化STL`vector`子对象；因为`initializer_list`本身是一个新的标准类型，自然可以将其放入函数参数中传入。

我们还可以用`initializer_list`来构造结构体对象，而不需要在C++03中的一样将non-POD类型中的对象写在函数体当中（因为C++03不允许用初始化列表初始化非POD）；甚至在`getDefault`中还可以通过初始化列表隐式构造一个新的对象返回。

## Type interface
------------------

STL模板类型的引入使得C++的类型系统变得异常复杂，尤其在调试的时候，出错信息可能非常恐怖难懂；C++11通过引入`auto`和`decltype`使得类型系统在很多时候可以自动推倒出表达式类型，极大简化了代码：

{% gist 3383906 type-interface.cpp %}

- auto 可以根据上下文自动推倒出变量类型，STL的for循环变得更简单   
- decltype 可以*解析*一个变量的类型并用来生成一个同类型的变量

## Range based for
------------------

许多动态语言都提供了`for（x in y)`方式的循环写法来遍历某个列表或者容器，C++11也加入了这一新潮的特性来提高编码效率,并且结合`auto`可以大大简化代码：

{% gist 3383906 for_range.cpp %}


## Trailing return type
-----------------------
这个特性用于简化模板代码的书写，譬如如下的代码在C++03中是非法的：
``` c++
template<class Lhs, class Rhs>
  Ret adding_func(const Lhs &lhs, const Rhs &rhs) {return lhs + rhs;} //Ret must be the type of lhs+rhs
```
为了模板函数的灵活性，`Ret`类型必须被指定为一个合理的动态类型-即根据实际传入的LHS/RHS来确定，当然人工指定的办法很不灵活，我们自然希望编译器能够自动推倒，一种自然的想法是尝试用`auto`:
``` cpp
template<class Lhs, class Rhs>
  decltype(lhs+rhs) adding_func(const Lhs &lhs, const Rhs &rhs) {return lhs + rhs;} //Not legal C++11
```
可惜这仍然是非法的，因为decltype需要编译扫描的时候必须知道对应参数的类型，而这些信息只有在模板函数实例化的时候才有。为了解决这一个问题，C++11引入了*Trailing return type*:
``` cpp
template<class Lhs, class Rhs>
  auto adding_func(const Lhs &lhs, const Rhs &rhs) -> decltype(lhs+rhs) {return lhs + rhs;}
```

## 构造函数委托
C++03标准中，一个类的构造函数是不允许调用另外一个构造函数的，这就导致很多共同的初始化代码不得不放置在一个共有的**非虚**函数中，然后在所有的构造函数版本中都得调用这一初始化代码。新的C++11中放开了这一限制，使得一个构造函数可以调用另外一个更通用的构造函数.对于类的继承构造中，子类的构造函数只有在基类的所有委托构造全部完成之后才会开始构造子类的部分：

- 构造函数执行的时候，对象的类型已经变成已知的  
- 任意一个构造函数被执行完毕的时候，C++11即认为该对象构造完毕  
- C++11允许基类指定其构造函数是否应该被继承（只能是全部被继承或者全部没有），这样子类构造的时候，编译器会适时去构造基类的构造函数  

## Explicit overrides && final
------------------------------
C++03标准中，某个子类可能会默默覆盖了基类的虚函数 - 譬如子类定义了一个和基类虚函数同名但是签名有微小差异的函数，结果就是产生预料之外的结果。C++11中引入了`override`和`final`来解决这个问题：
```cpp
struct Base {
    virtual void some_func(float);
    };
     
struct Derived : Base {
    virtual void some_func(int) override; // ill-formed because it doesn't override a base class method
    };
```
这里加入`override`关键字，编译器就会检查是否是和基类中的虚函数签名完全相同，否则就报错。

`final`则完全是从其它语言学习的特性，某个类如果声明为final，则这个类就是不能被继承的，如果某个函数是`final`,则任何尝试重写该函数的子类都会引起编译错误。

## nullptr
---------------

这个纯粹是为了解决NULL和0的含糊不清的历史问题；引入`nullptr`之后，函数重载就变得简单了。

## 类型安全的枚举类型 
---------------------

C++03中的枚举类型并不是类型安全的，你可以拿两个类型不同的枚举类型值来做比较而编译器不会给出任何错误。C++11中通过`enum`后边加入`class`来引入类型安全的枚举类型：
```cpp
enum class Enumeration {
    Val1,
    Val2,
    Val3 = 100,
    Val4 // = 101
};
```
这样就不能直接拿枚举类型值和普通数值类型做比较了。此外，新的枚举类型可以指定所使用的整形具体类型：
```cpp
enum class Enumeration : unsigned int{
    Val1,
    Val2,
    Val3 = 100,
    Val4 // = 101
};
```
这样也使得枚举类型可以前向声明了。

## 右扩号的问题修正
---------------------
这是一个bug fix，使得这样的代码变得合法：
``` cpp
std::vector<std::pair<int, int>> vec;
```

## 模板typedef
-------------------------
C++11中允许typedef一个部分参数指定的模板，譬如：
```cpp
template <typename First, typename Second, int Third>
class SomeType;
 
template <typename Second>
using TypedefName = SomeType<OtherType, Second, 5>;
```
这一小便利大大简化了模板代码的书写和使用。

## Union类型可以放置non-POD
------------------------------
C++03中，Union中不可放置POD类型意外的东西，而C++11中，我们可以放置任何类型到Union中了：
```cpp
/for placement new
#include <new>
 
struct Point  {
    Point() {}
    Point(int x, int y): x_(x), y_(y) {}
    int x_, y_;
};

union U {
    int z;
    double w;
    Point p;  // Illegal in C++03; point has a non-trivial constructor.  However, this is legal in C++11.
    U() { new( &p ) Point(); } // No nontrivial member functions are implicitly defined for a union;
    // if required they are instead deleted to force a manual definition.
};
```

## 参考
------------
1. [Wikipedia on C++11](http://en.wikipedia.org/wiki/C%2B%2B11#Core_language_usability_enhancements)  
2. [oopscenities blog](http://oopscenities.net/tag/cpp11/)

