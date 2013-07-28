---
layout: post
title: "ruby学习笔记-4 class&amp;module"
date: 2012-03-06 22:48
comments: true
categories: [学习笔记, ruby]
---

Class和Module是Ruby中的两个重要概念。作为一个纯**OO**语言，class的概念自然容易理解，即为object的抽象；而module则明显有别于其它语言地提供了mixin方法来解决多继承缺失带来的不便 - 集成多个基类的接口并维持[IS-A关系](http://en.wikipedia.org/wiki/Is-a)以及[LSP替换](http://en.wikipedia.org/wiki/Liskov_substitution_principle).

<!--more-->

## 相互关系和一些基本类

ruby中存在一些基础的类（或者是MetaClass)，包括: `[Class, Module, Kernel, Object, BasicObject]`, 且看如下测试：
``` ruby
tests = [Class, Module, Kernel, Object, BasicObject]

puts "checking class and ancestors for #{tests}"
tests.each do |x|
  puts "Ancestors of #{x} is #{x.ancestors}"
  puts "The class of #{x} is #{x.class}"
end

puts ""
def check_is_a(a, b)
  if not a.is_a? b
  puts "#{a} is not a #{b}"
  end
end

puts "checking is_a relation for #{tests}"
tests.each do |x|
  tests.each do |y|
    check_is_a(x, y)
  end
end
```

输出结果如下：
```
checking class and ancestors for [Class, Module, Kernel, Object, BasicObject]
Ancestors of Class is [Class, Module, Object, Kernel, BasicObject]
The class of Class is Class
Ancestors of Module is [Module, Object, Kernel, BasicObject]
The class of Module is Class
Ancestors of Kernel is [Kernel]
The class of Kernel is Module
Ancestors of Object is [Object, Kernel, BasicObject]
The class of Object is Class
Ancestors of BasicObject is [BasicObject]
The class of BasicObject is Class

checking is_a relation for [Class, Module, Kernel, Object, BasicObject]
Kernel is not a Class
```

可见，Kernel本身是个Module，但不是一个Class，其它的都互相满足is-a关系。其它任何一个class都是一个module（但是并不意味着可以include class）。

## 构造测试

Module不能用new来生成一个对象，譬如：
``` ruby
module TestModule
  def func()
    puts "value is @value"
  end
end

begin
  obj = TestModule.new
  obj.func()
rescue Exception => e
  puts "Module new got an exception: #{e.class}"
end
```
这里会抛出`NoMethodError`异常。

## MIXIN

Module的主要作用就是实现MIXIN。通过Module，某个class可以通过`include`某个module来包含其所定义的方法。module起的作用类似于抽象基类，所有module定义的方法可以被子class调用或者重写。

下边的这段代码是一个简单的MIXIN例子:
``` ruby
class BaseClass
  def call_func()
    puts "base called"
  end
end

class MixInClass < BaseClass
  include TestModule
  def initialize(value)
    @value = value
  end

  def call_func()
    super
    puts "called in child"
  end

  def func()
    super
    puts "module func called"
  end
end

obj = MixInClass.new("mixin")
obj.func()
# module method called
obj.call_func()
# virtual method called which will call it's ancestor by super
```

上述代码中，`super`用于调用`BaseClass`或者对应Module中的方法。

## 方法冲突的解决

通过MIXIN，一个Class可以通过include来MIXIN多个module的方法。如果有两个module中存在同名的方法，行为又会如何？下边是一个例子：
{% include_code dupFuncInModule.rb dupFuncInModule.rb %}

运行结果如下：
```
called in BaseModule2
unique func in module1
unique func in module2
```

从而可得如下结论:  

- 同名的方法，优先选择module中的定义  
- 如果有module方法名字冲突，ruby选择最近的一个include的module的实现   
- 由于不可能集成多个base class，就不可能出现在base class冲突的情况    

### initialize方法处理

module的initialize方法处理规则有些特殊，如下例：
{% include_code moduleInitialize.rb moduleInit.rb %}

运行结果如下：
```
called with value = test1
called with value = test2
my value is: test2
called with value = 
called with myvalue = test3
```
这里有三种处理情况：

- 包含module的class没有定义`initialize`函数,module的`initialize`函数会被调用   
- class中定义了`initialize`,并且其中调用了`super`,module的`initialize`函数会被调用    
- class虽然定义了`initialize`,但是没有调用`super`,则module的`initialize`不会别调到   

这里还有另外一种情况即如果class的BaseClass也定义了initialize,如下述代码：
{% include_code moduleInitializeWithBase.rb moduleInitConfuse.rb %}

结果如下:
```
called with value = test1
my basevalue=
```

这里，module的`initialize`方法有较高的优先级，即`super`调用会首先调用module的同名函数。


## 参考
- [Class, Module, Object,Kernel的关系](http://www.cnblogs.com/cnblogsfans/archive/2009/01/27/1381134.html)
- [Ruby Mixin tutorial](http://juixe.com/techknow/index.php/2006/06/15/mixins-in-ruby/)
- [Ruby中module和class的区别](http://www.51testing.com/?uid-128701-action-viewspace-itemid-153316)

