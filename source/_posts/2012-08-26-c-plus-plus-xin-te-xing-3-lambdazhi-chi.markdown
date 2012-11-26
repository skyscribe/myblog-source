---
layout: post
title: "C++新特性3 - Lambda支持"
date: 2012-08-26 11:23
comments: true
categories: [cpp, cpp11, 学习笔记]
---

**lambda表达式(closure)**是C++11中新引入的对程序组织构造改进最大的特性之一；这一特性并不是一个新的概念（几十年前的函数式于样都提供了该特性），然而对于一个深受*过程式思维*影响的语言而言，lambda的支持则极大提高了代码的抽象能力和可读性。

<!--more-->

## 一个简单的例子  

考虑下边的例子(很简单常见的例子，但很容易说明问题)：

``` cpp
class AddressBook;
typedef std::vector<AddressBook> AddressList;
void getPeopleWithAge(AddressList& result, const AddressList& list, int age){
    std::transform(list.begin(), list.end(), std::back_inserter(result), ageEqualsTo(age));
}
//Define a Functor for ageEqualsTo(int)
```
这里我们想从一个地址本里边找出所有的年龄等于给定年龄的项并将结果返回，然而为了使用STL标准算法*transform*，我们不得不构造一个Functor出来填入最后的一个参数，麻烦不说，真正想表达的逻辑还被迫分隔到另外一个Functor去了；既然如此，还不如直接拿一个**for**循环来得快些：

```cpp
void getPeopleWithAge(AddressList& result, const AddressList& list, int age){
    for (auto it = list.begin(), itEnd = list.end(); it != itEnd; ++it){
        if (it->age == age){
            result.push_back(*it);
        }
    }
}
```

然而利用lambda，代码可以变得更加简洁优雅：

```cpp
void getPeopleWithAge(AddressList& result, const AddressList& list, int age){
    std::for_each(list.begin(), list.end(), [=, &result](const AddressBook& item){
        if (item.age == age){
            result.push_back(*it);
        }
    });
}
```

这里我们既可以利用现有的STL抽象来操作，有不失程序的局部行，视线的逻辑也变得更清晰 - 直接遍历所有的元素，找出满足条件的部分并添加到目的列表中。判断条件的部分也直接嵌入在代码中，可谓性和可读性都大大提高；基本上操作STL容器的遍历操作就再也不需要手工写for循环了。

## Lmabda语法

C++11中的lambda语法定义如下：
```cpp
//context variables ....
[variable capture](param1, parm2, ...) -> returnType {
    //implementation body
    }
```

这里的`[]`里边的部分，可以用来包含上下文数据，可以用以下方式传入：  

- **[&]** 引用传递，所有lambda内的修改改变的是外部的变量   
- **[=]** copy语义，lambda内看到的是上下文变量的一份拷贝   
- **[=, &a, &b]** 默认copy，对a/b采用引用方式    

如果没有指定capture部分，那么所有的上下文数据都不可见，相当于定义了一个匿名函数；如果没有指定默认的capture，而是显式指定每一个变量，那么没有列出的变量在lambda里边都是不可见的。

`()`中间的部分是参数列表，如果套用到STL算法中去，需要注意对应的参数必须对应，否则编译会出错。

`->`的部分用于指定该lambda的返回类型，大部分情况下，编译器可以帮助推导出返回类型，我们就不需要显式指定返回类型。`{}`里边的部分是具体实现代码，可以像写普通函数一样写入代码，并且可以引用`[]`里边的变量（或者所有上下文变量，如果指定了默认capture类型）和函数参数变量。

## lambda的本质

lambda的本质其实是一个函数，编译器会在编译的时候帮助我们推导合适的类型，并且生成对应的函数，我们也可以将lambda赋值给一个变量，来实现延迟调用：

```cpp
auto f = [&]{
    a += 1;
    b *= 2;
    return a + b + c;
    };

f();
```
甚至可以将lambda函数传入模板参数：
``` cpp
// Lambda as template parameters
template <typename F>
void Eval(const F& f){
    f();
}

void foo(){
    Eval([]{cout << "Hello lambdas\n" << endl;});
}
```

需要格外小心的是，如果使用lambda来实现延迟调用，那么所应用的上下文里边的指针或者引用必须在调用点还是有效的，否则就会产生莫名其妙的对象生存期错误导致的crash等问题。

如果我们仔细看TR1库的function/bind，还可以发现lambda在很多情况下可以简化代码，减少一些不必要的bind，因为上下文数据可以很容易的嵌入的代码块中了，这样也大大减小了functional/bind带来的逻辑分割问题。


## 参考资料
1. [Lambda Functions in C++11 - the Definitive Guide](http://www.cprogramming.com/c++11/c++11-lambda-closures.html)  
2. [C++11 wikipedia](http://en.wikipedia.org/wiki/C%2B%2B11#Lambda_functions_and_expressions)  

