---
layout: post
title: "Python中根据不同参数组合产生单独的test case的一种方法"
date: 2009-10-12 21:20
comments: true
categories: [python, test, automation, tips]
---

Python自带的unittest和test两个模块为编写test case提供了很灵活的支持，最常用的情况就是继承自unittest.TestCase类，然后对每一个要进行测试的行为写一个test_开头的类成员函数，最后可以利用test.test_support.run_unittest函数跑所有的test case.

在某种情况下，可能需要用不同的参数组合测试同样的行为，这些行为要么很耗时间（譬如下载数据），要么是你希望从test case的执行结果上知道在测试什么，而不是单单得到一个大的 test case；此时如果仅仅写一个test case并用内嵌循环来进行，那么其中一个除了错误，很难从测试结果里边看出来。

<!--more-->

问题的关键在于是否有办法根据输入参数的不同组合产生出对应的test case；譬如你有10组数据，那么得到10个test case，当然不适用纯手工的方式写那么多个test_成员函数。
一种可能的思路是不利用unittest.TestCase这个类框中的test_成员函数的方法，而是自己写runTest这个成员函数，那样会有一些额外的工作，而且看起来不是那么“智能”，如果目的是让框架自动调用testcase.
 
 自然的思路就是

- 利用setattr来自动为已有的TestCase类添加成员函数  
- 为了使这个方法凑效，需要用类的static method来生成decorate类的成员函数，并使该函数返回一个test函数对象出去  
- 在某个地方注册这个添加test成员函数的调用(只需要在实际执行前就可以，可以放在模块中自动执行亦可以手动调用)  

最后的代码就有了：

``` python
import unittest
from test import test_support

def MyTestCase(unittest.TestCase):
    def setUp(self):
        #some setup code
        pass
       
    def clear(self):
        #some cleanup code
        pass
       
    def action(self, arg1, arg2):
        pass
       
    @staticmethod   
    def getTestFunc(arg1, arg2):
        def func(self):
            self.actions(arg1, arg2)
        return func
        
def __generateTestCases():
    arglists = [('arg11', 'arg12'), ('arg21', 'arg22'), ('arg31', 'arg32')]
    for args in arglists:
        setattr(MyTestCase, 'test_func_%s_%s'%(args[0], args[1]),
            MyTestCase.getTestFunc(*args) )
__generateTestCases()
      
def test_main():
    test_support.run_unittest(MyTestCase)
```

如此，添加一个新的可变参数组合，就会新生成一个test case， 只需要将参数组合添加到arglist中就可以了。
