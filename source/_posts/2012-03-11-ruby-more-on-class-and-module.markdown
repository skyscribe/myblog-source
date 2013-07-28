---
layout: post
title: "ruby 学习笔记 5 - class&module&methods"
date: 2012-03-11 20:45
comments: true
categories: [学习笔记, ruby]
---

和其它的面向对象语言类似，ruby的类方法也分为_class method_ 和 _instance method_, **module**和**class**具有相当大程度的相似性, 但是用于重用module中定义的方法时( 同样也有 class method 和 instance method 之分 )，又有一些微妙的差异。

<!--more-->

## class method定义

遵循[perl的设计哲学](http://www.technomanifestos.net/index.pl?Perl_slogans)，ruby中的class method也有三种方法，分别如下：

1. 类内define法，需要在 method name 之前显示加上 self 指明这是个属于 class 的方法：  

``` ruby
class Test
    def self.foo
        puts "class method called"
    end
end
# call
Test.foo
```  
2. Append 法，通过 << 添加到 self，如下：  

``` ruby
class Test
    class << self
        def foo
            puts "class method called"
        end
    end
end

# call
Test.foo
```   
3. 类外定义，和定义一个普通函数的方法类似，但是指明了 class name， 可以用于方便的向已定义好的类中添加 class method:  

``` ruby
class Test; end
def Test.bar
    puts "class method called"
end
#call
Test.bar
```

## include/extend

当 module 中的方法被新的类通过**MIXIN**方法包含的时候，module中定义的方法在新的类中是被定位为 class method 还是定义为 instance method? 答案取决于包含 module 的方法，这里是一段测试代码：

{% include_code test_include_extend.rb test_include_extend.rb %}

运行结果如下：

```
undefined method `foo' for NewClsIncludeModule:Class
foo
undefined method `foo' for #<NewClsExtendModule:0x9c4436c>
```

这里的输出表明:

* 以 include 方法包含的 module 其定义的方法会被解析为 instance method, 即 include 包含 instance methods
* 以 extend 方法包含的 module 其定义的方法会被解析为 class method, 即 extend 扩展 class methods

## 扩展 module 的习惯用法  

尽管 include 和 extend 分别用于扩展 instance method 和 class method, 我们还是可以采用一种惯用法来同时包含一个module的 instance methods 和 class methods. Rails 就利用了这种惯用法： **用 include 同时添加 instance methods 和 class methods**。其原理如下：

1. 任何 object 都是Object的子类实例，而 Object 本身继承自Kernel  
2. Kernel module 定义了 include 方法，其中会调用 self.included   
3. 这个 included 可以被用来修改包含 module 方法的类   
4. 定义 module 的时候，用一个 sub module 来定义所有的 class methods  
5. 在 module 中重写 included 方法，调用 extend 来扩展上述 sub module 中的 methods 为 class methods  

例子如下：
{% include_code module_include_idiom.rb module_include_idiom.rb %}


## 参考链接
1. [Class and Instance Methods in Ruby](http://railstips.org/blog/archives/2009/05/11/class-and-instance--in-ruby/)  
2. [Include vs Extend in Ruby](http://railstips.org/blog/archives/2009/05/11/class-and-instance-method-in-ruby/)   
3. [Ruby 的 include 和 extend ](http://blog.csdn.net/rocky_j2ee/article/details/3754781)  
4. [Mixins in Ruby](http://juixe.com/techknow/index.php/2006/06/15/mixins-in-ruby/)  
