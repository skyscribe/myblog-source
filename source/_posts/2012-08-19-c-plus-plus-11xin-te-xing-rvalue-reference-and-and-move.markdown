---
layout: post
title: "C++11新特性2-RValue Reference 与 Move"
date: 2012-08-19 09:40
comments: true
categories: [cpp, tips, cpp11, 学习笔记]
---

现有的C++03标准中，不必要的对象的拷贝和临时对象的构造经常会造成额外的性能开销（即使有*返回值优化*这样的编译器优化来帮忙也不能解决好多情况的问题）；新的C++11标准通过对语言的修正，引入了**RValue Reference**和**Move**来解决这一问题。

<!--more-->

## RValue Reference
-------------------

### Rvalue && Lvalue

C++中的Rvalue和Lvalue是从C中继承过来的概念，但是由于本身语言特性的扩充，使得两个概念本身和C中的又有所不同。在C中，我们可以简单理解为：

* Lvalue - 所以可以放在**=**左侧的东西   
* Rvalue - 不能放在=左侧的东西  

但是这一理解到C++中则不再完全成立；譬如对于用户自定义的对象a,b,c,并且重载了`+`/`*=`运算符,那么表达式中 `((a+b)+c) *= 2`, `(a+b)`虽然出现在左侧，却是一个Rvalue。一个更好的解释方式可以总结为：

* Lvalue - 指向了一块内存区域并且我们可以用`&`取其地址的对象引用  
* Ralue - 不能对对应内存取地址的对象引用  

这一解释虽然也有不完全正确的地方，但是不影响绝大部分情况的讨论。

### Rvalue reference

C++03中，我们可以定义引用类型，用于给一个对象指定别名，这样当一个昂贵的对象在函数之间传递的时候，就不需要额外的对象拷贝/构造的开销；然而我们却不能直接将`rvalue`传给一个普通的引用类型函数参数，除非参数被生命为*const*引用；然而当一个rvalue对象传递给一个const的lvalue reference参数的时候，一个新的临时对象就必须被创建，并且在函数返回的时候被自动销毁；这就带来了不必须的性能开销；如果我们能直接将rvalue对象通过引用方式传递给函数内而不需要构造新的临时对象的话，对象构造析构的开销就可以去掉。

C++11通过引入**Rvalue Reference**的方式来达到这一目的。仔细考虑下这里的情形，rvalue引用了一个临时的对象，这个对象被传入函数内部，并且在执行完毕之后被销毁，可以想象为对应的临时对象被**Move**到了函数内部；因为外部无法直接看到这个临时对象，因而这里的**Move是安全的**.

C++11引入的Rvalue Reference主要是为了解决两个问题：

1. 实现*Move 语义*  
2. 解决模板编程中的转发问题，实现完美转发  

### Rvalue定义

C++03中，不允许定义引用的引用，即`X&& b = x`;而C++11正好借用这个符号来表述Rvalue reference, 即： 
``` cpp
class X;
void func(X&& obj){
}

X getX(){
    //some operation to get an X
}

void func1(){
    
    func(getX());
}
```

这里的X对象在`func`中会被转化为一个Rvalue,传入`func`中调用。

## Move
------------------

### Move 语义

考虑如下的例子：  
```cpp
X& X::operator=(const X& rhs){
    // check if rhs equas to this and then
    //  detach rhs's resource and make a clone of its resouce
    //  and then attach to this
}

X foo();
X x;
x = foo();
```

这里最后一行语句会析构`foo`所返回的临时对象，并将对应的对象拷贝至`x`，而实际上我们完全可以直接将`foo()`返回的对象直接**Move**到`x`中来。这里我们就可以通过定义重载`move`语义的`operator =`:
```cpp
X& X::operator=(X&& rhs){
    //swap resource
}
```

### 强制Move

某些情况下，编译器不会自动为我们选择`rvalue`版本的函数，譬如：  
```cpp
template<class T>
void swap(T& a, T& b) 
{ 
    T tmp(a);
    a = b; 
    b = tmp; 
} 

//Define move assignment and move copy constructors for X
X a, b;
swap(a, b);
```
这里因为传入的变量a/b并不会按照`move`方式传递，而是继续调用旧有的方式去构造。问题在于这里的a/b在编译器看来可能后续会被继续引用修改，因此他们自身并不是rvalue；C++11引入了`std::move`函数来强制move:
```cpp
template<class T>
void swap(T& a, T& b) 
{ 
    T tmp(std::move(a));
    a = std::move(b); 
    b = std::move(tmp); 
} 
```

### swap来实现对象move的问题

如果我们用简单的**swap 资源**的方式来实现move语义，那么假如被move的对象就会指向了对应目标对象的资源而没有被真正析构。如果对应的对象资源有副作用，那么结果就会变得很诡异；因此任何有副作用的move实现必须保证被move的对象处于一个可以被析构的状态，并且其有副作用的部分应该被正确销毁。

### 确定Rvalue版本被正确调用

考虑下边的例子：
```cpp
void foo(X&& x){
    X anotherX = x;
}
```
这里我们虽然传入了一个`Rvalue`引用，但是函数体中的对象拷贝赋值却不会调用对应的`move`版本；因为这里的`x`本身有名字，因此它会被编译器认为是一个`lvalue`，因此旧的拷贝构造会被调用。反之，如下的例子却能正确调用`move`版本：
```cpp
X&& bar();
X x = bar();
```

如果我们想要显式调用`move`版本，那么可以用`std::move`来强制，但是我们就要注意后边不能在引用这个变量了，因为其持有的资源已经被`move`了。

这个问题对于类继承的情况就更明显：
```cpp
//Base class provides move implementation for construction
class Derived(Derived && rhs) : Base (rhs){
    //Derived initialization....
}
```
这里的基类部分的构造**不会调用move版本**仅仅是因为我们传入了一个有名字的变量给它，解决的办法仍然是`std::move`:
```cpp
//Base class provides move implementation for construction
class Derived(Derived && rhs) : Base (std::move(rhs)){
    //Derived initialization....
}
```

### move与返回值优化（RVO）

现代的编译器大多实现了返回值优化来减少临时对象的构造，然而这一优化可能会对我们的`move`产生影响：
```cpp
X foo(){
    X x;
    //do something with x
    return x;
}
```
乍一看可能以为我们可以用move来避免函数内对象到返回值中的对象的拷贝，然而“聪明”的编译器可能已经优化了这一临时对象，即使用`std::move`也会是多次一举。

## Perfect forwarding
---------------------

在模板编程中，`perfect forwarding`是一个麻烦的问题，譬如如下的forward函数用于构造一个给定类型的对象：

```cpp
template<typename T, typename Arg> 
shared_ptr<T> factory(Arg arg)
{ 
  return shared_ptr<T>(new T(arg));
} 
```

这里的目地是用给定的参数返回一个新的对象指针；问题是这里的参数是用copy传递的，如果参数对象比较昂贵，就有不必要的开销被引入；加入我们换做引用传递：

```cpp
template<typename T, typename Arg> 
shared_ptr<T> factory(Arg& arg)
{ 
  return shared_ptr<T>(new T(arg));
} 
```

问题虽然得到部分好转，但是不完美，譬如我们就无法传入一个rvalue: `factor<X>(41)`就会报错。一种解决的办法是，对这个模板函数再加上一个const引用版本的；虽然问题可以得到解决，但是随着函数参数个数的增加，需要重载的版本也就成倍增加了。解决这一问题的方法为:

```cpp
template<typename T, typename Arg> 
shared_ptr<T> factory(Arg&& arg)
{ 
  return shared_ptr<T>(new T(std::forward<Arg>(arg)));
} 

template<class S>
S&& forward(typename remove_reference<S>::type& a) noexcept
{
  return static_cast<S&&>(a);
} 
```

这里的奥秘在于`Arg`参数的解析，在C++11中，`&`的解析遵循如下规则：  

- A&& => A&  
- A& && => A&  
- A&& & => A&  
- A&& && => A&&  

这样，无论传入的Arg是lvalue还是rvalue,对应的正确版本都会被正确调用。

## 参考
1. [Wikipedia C++11](http://en.wikipedia.org/wiki/C%2B%2B11#Rvalue_references_and_move_constructors)     
2. [C++ Rvalue Reference Explained](http://thbecker.net/articles/rvalue_references/section_01.html)     
3. [Lvalues and rvalues](http://accu.org/index.php/journals/227)  
