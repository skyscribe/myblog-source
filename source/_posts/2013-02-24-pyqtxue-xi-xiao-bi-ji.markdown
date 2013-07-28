---
layout: post
title: "PyQt学习小笔记"
date: 2013-02-24 09:39
comments: true
categories: [pyqt, qt, python, GUI]
---

PyQT是知名跨平台框架QT的python绑定；用它来做些小程序既可以利用QT的跨平台性又能利用python强大的表达能力,从而取得事半功倍的效果。下边是使用它开发一个小程序过程中的学习小笔记。

<!--more-->

## UI界面设计 ##

### QT Designer ###

使用过VC做过MFC开发的，对**所见即所得(WYSIWYG)**的工具不会陌生，QT Designer就是类似的一个。其设计就是将代码和UI空间分开，控件布局和对象名称都可以在里边设置，每个空间都有对应的属性表，可以针对很多控件属性做默认定制。最后生成对应的python代码。

### 生成代码 ####

生成的代码主要集中于控件显示的部分，事件处理的部分虽然也可以产生，但是仅适用于自定义子类的对象，因为在slot里边没法很方便的为已有的某个UI对象添加新的方法，只能靠子类化的办法来修改类的预定义slot，远不如在代码中自己写来的快捷方便。

每个界面的设计最终会生成一个**.ui**后缀的XML文件，使用如下的Makefile规则可以做方便的转换：
``` bash
%.py : %.ui
    pyuic4 $^ > $@
```

### 尽量少混杂动态控制逻辑到UI设计中 ####

对于某些需要多步骤协作完成某个特性的控件，在Designer里边修改一部分属性，然后再在代码中完成另一部分是不方便的。譬如设计一个弹出的对话框，如果想设置它为`Modal`的，那么最好还是在代码里边，在创建的时候设置要来得方便和清晰的多；否则除了问题，排查起来就比较麻烦。


## 逻辑实现和控制  ##

### 简单控件和逻辑事件 ###

简单的控件使用，有过MFC开发经验的自然容易照搬来做，基本都很像。唯一有些不同的是，在python里边，绑定事件处理的方式灵活了很多，不但可以用`QObject`类的`connect`方法来做，也可以直接在signal对象上来直接绑，而且绑定的参数可以是任何的`callable`，譬如：
```python
#Option 1
self.ui.btnAdd.clicked.connect(self._addRecord)
#Option 2
QtCore.QObject.connect(self.btnOk, QtCore.SIGNAL(_fromUtf8("clicked()")), EditDlg.accept))
```
对于显示空间，QT支持对它的显示特性做CSS定制，但是在Designer里边必须指定允许扩展stylesheet，然后可以在对于的stylesheet里边设置样式；对应的编辑框里边还提供颜色选择和渐变选择等图形工具。如果需要实现动态的样式变化，则需要在代码逻辑中完成。

### 一些复杂的控件设计 ###

#### 菜单和状态栏 ####
可以在Designer中选择是否需要菜单栏和状态栏。如果没有设置，那么在生成的代码里边调用`menuBar()`或者`statusBar()`这样的函数也会创建一个新的，但是对应的显示属性就必须完全自己代码设置了。

#### 表格控件和数据操作 ####

QT的表格控件可以映射到二位数组，其实现建立在它自己的模型/视图框架之上，可参考`QAbstractItemView`类的文档。简单说来，是需要提供一个数据模型类,在该数据模型类里边封装底层的实际数据，并且至少实现如下方法：  
1. `rowCount()` 提供表格的行数  
1. `columnCount()` 提供表格的列数据个数   
1. `headerData()` 提供表格表头数据显示或者修改  

以上的方法可以提供一个只读的表控件。如果需要支持可编辑表格(已经显示的数据部分)，则需要以下方法：  
1. `setData()` 完成数据设置  
1. `flags()` 需要返回一个可编辑的标记   

如果需要支持记录的增加/删除/修改，则需要：  
1. `insertRows()` 完成实际数据的增加操作，并在开始的时候调用`beginInsertRows()`,操作完毕的时候调用 `endInsertRows()`   
1. `removeRows()` 完成数据的删除操作,开始操作之前调用`beginRemoveRows()`,完毕之后调用`endRemoveRows()`   
1. `insertColumns()` 完成列数据增加操作,数据操作需包在`beginInsertColumns()`和`endInsertColumns()`之间   
1. `removeColumns()` 列删除，操作需要被`beginRemoveColumns()`和`endRemoveColumns()`之间   

需要对表格列进行排序，则需要自己实现`sort()`函数，根据传入的列编号和排序方法，对实际数据进行排序，并且在排序之前，发送`layoutAboutToBeChanged()`通知信号，完成排序之后，发送`layoutChanged()`信号。

当然也可以自己写函数完成修改操作，但是如果牵扯到记录行列的改动，则必须保证对于的`begin`和`end`方法被正确调用，否则界面的数据可能无法正确刷新。

#### QModelIndex ####

大部分的数据操作都携带一个Index参数，该参数负责定位对应的具体数据，并且精确定位到某一个单元格，可以用切`row()`和`column()`方法得到其行/列编号。也可以通过给定的行/列号构造一个Index；但是该参数并不能直接定位行数据。在跟踪用户选择的时候，选择的是一整行数据的话，返回的选择列表包含所有的单元格；如果想获取行，则需要对行号做如下变换：  
```python
rows = list(set([index.row() for index in selected.indexes()]))
```
上述的代码利用set的特性将多余的行自动删除，并且再转换回list的时候已经是排序过的。

#### Selection Model ####

如果想跟踪用户的选择并获取通知，则需要绑定对于的selectionModel对象的相关信号。具体的定义可参考`QItemSelectionModel`的 singla/slot部分。对应的定位方法仍然是依据单元格。

如果对于的model数据发生变化(譬如调用了`setModel()`)，那么对于的selectionModel会发生变化。

## 如何利用QT的文档 ##

QT的官方文档都是针对C++的，对于Python绑定并没有提供专门的文档，因此 stackoverflow 上也有很多的提问；总结起来，可以有下边几种办法 :

- 使用QT的官方文档 - 本地装一个，用浏览器打开其页面就是,很方便的展开看类结构和每个类的概要文档  
- [PySide网站](http://qt-project.org/wiki/PySide_Binaries_Linux)的文档, 提供各个平台的安装包  
- 使用**bpython**工具，手工导入包，然后可以看每个类方法的文档  

