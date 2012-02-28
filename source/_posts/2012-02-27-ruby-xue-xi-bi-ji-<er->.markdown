---
layout: post
title: "ruby 学习笔记<二>"
date: 2012-02-27 20:36
comments: true
categories: [ruby, 学习笔记]
tags: [study, ruby, language]
---

## blocks&&closure
ruby的blocks和closure特性明显有别于其它的语言，其closure本身是__real closure__，所绑定的context是共享的而非copy，其设计思路和_lisp_的相同；blocks本身则可以用于实现closure。二者的关系如下所述 [link](http://www.artima.com/intv/closures2.html)

> __Yukihiro Matsumoto__ You can reconvert a closure back into a block, so a closure can be used anywhere a block can be used. Often, closures are used to store the status of a block into an instance variable, because once you convert a block into a closure, it is an object that can by referenced by a variable. And of course closures can be used like they are used in other languages, such as passing around the object to customize behavior of methods. If you want to pass some code to customize a method, you can of course just pass a block. But if you want to pass the same code to more than two methods -- this is a very rare case, but if you really want to do that -- you can convert the block into a closure, and pass that same closure object to multiple methods.

<!--more-->

## 7种结构

### block方式3种

- 隐式传入，内部用yield调用

        def thrice
          yield
          yield
          yield
        end

        x=1
        thrice {x+=2}

    这里的block代码在内部调用的时候实际被执行。每个yield调用执行一次所传入的block代码,_x_的实际值以引用方式加2.

    这也是最常见的一种方式；block里边也可以包含一个或者多个参数，实际参数在yield调用的时候被传入。

- &block 参数传递

        def six_times(&block)
          thrice(&block)
          thrice(&block)
        end

        x = 4
        six_times {x+=2}

    和前一方式很类似。

- &block传入，保存block为变量，然后调用block.call

        def save_for_later(&b)
          @saved = b  # Note: no ampersand! This turns a block into a closure of sorts.
        end
           
        save_for_later { puts "Hello!" }
        puts "Deferred execution of a block:"
        @saved.call
        @saved.call

    这里的block被显式的保存到一个instance variable中（这里是__main__对象）, 后续在调用点的可以之间使用变量的call方法来延迟调用。

- proc.new/proc

        @saved_proc_new = Proc.new { puts "I'm declared with Proc.new." }
        @saved_proc = proc { puts "I'm declared with proc." }
        @saved_proc_new.call
        @saved_proc.call

    这两种方式的效果实际差不多,直接将block对象生成的closure保存在变量中，并且可以后续调用。

- lambda

        @saved_lambda = lambda { puts "I'm declared with lambda." }
        @saved_lambda.call

    此法采用显式的lambda函数生成closure，然后保存于变量并可延迟调用。

- method
    
        def some_method
          puts "I'm declared as a method."
        end
        @method_as_closure = method(:some_method)

    这里用一个symobl传入method，生成一个closure。

## 特点和差异

- return 行为
    
    当对应的block里边包含return的时候，上述7中方式有些许的不同：

    {% include_code [closure_return.rb] [lang:ruby] closure_return.rb %}

    运行结果如下：

            skyscribe:~/program/octopress/source/downloads/code$ ruby closure_return.rb 
            before yield
            failure: LocalJumpError: unexpected return
            before calling #<Proc:0x8ad05f4@closure_return.rb:31>...
            during #<Proc:0x8ad05f4@closure_return.rb:31> failure: LocalJumpError: unexpected return
            before calling #<Proc:0x8ad0478@closure_return.rb:32>...
            during #<Proc:0x8ad0478@closure_return.rb:32> failure: LocalJumpError: unexpected return
            before calling #<Proc:0x8ad0310@closure_return.rb:35 (lambda)>...
            called #<Proc:0x8ad0310@closure_return.rb:35 (lambda)> result:value from proc
            before calling #<Method: Object#test_method>...
            called #<Method: Object#test_method> result:test method

        
    - lambda/method表现出真正的closure行为，仅仅返回closure本身；外部调用控制流不受影响，继续yield或者call的下一语句执行
    - 其它几种会跳出外部调用者的控制流，即return出调用者，yield/call之后的也不会再执行，直接跳出到最近的end外


- arity - 参数个数校验

    {% include_code [closure_return.rb] [lang:ruby] closure_arity.rb %}

    运行结果如下：

            skyscribe:~/program/octopress/source/downloads/code$ ruby closure_arity.rb 
            arity = 2
            less args for #<Proc:0x9ecffb4@closure_arity.rb:25> also work
            arity = 2
            less args for #<Proc:0x9ecff14@closure_arity.rb:26> also work
            arity = 2
            too few args for #<Proc:0x9ecfe9c@closure_arity.rb:27 (lambda)> throw ArgumentError: wrong number of arguments (1 for 2)
            arity = 2
            too few args for #<Method: Object#test_method> throw ArgumentError: wrong number of arguments (1 for 2)
            arity = 2
            more args also work for #<Proc:0x9ecfbe0@closure_arity.rb:30>
            arity = 2
            more args also work for #<Proc:0x9ecfb7c@closure_arity.rb:31>
            arity = 2
            too many args for #<Proc:0x9ecfb18@closure_arity.rb:32 (lambda)> throw ArgumentError: wrong number of arguments (7 for 2)
            arity = 2
            too many args for #<Method: Object#test_method> throw ArgumentError: wrong number of arguments (7 for 2)


    对于调用点的参数检查，呈现如下行为：

    - lambda/method严格校验参数的个数，如果不匹配回抛出异常
    - 其它几个不检查参数个数


## 小结

- lambda/method方式呈现完备的closure行为，return之后继续下一流程，对于实际传入参数个数会在调用点检查
- proc/blocks方式在return的时候直接返回了外部的函数或者block，对于传入的参数个数也没有执行检查。
