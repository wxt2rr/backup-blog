---
title: InnoDB几个索引数据结构的区别
date: 2020-09-10 12:25:00
summary: InnoDB几个索引数据结构的区别
categories: Mysql
tags:
  - InnoDB索引
  - Mysql
  - 数据结构
---
# 索引的本质

索引是帮助Mysql高效获取数据的==排好序==的==数据结构==

# 索引数据结构
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210628173241991.png)
假如有如上一张表，如果想要查询col2=23的那行数据，如果没有索引或者不走索引的话，那么将要查询7次才会查询到，并且这7行数据在磁盘里并不是挨着存储的，查询效率会非常低。

## 二叉树
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210628173314654.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MDI0Mzg5NA==,size_16,color_FFFFFF,t_70)


- 如上图，我们可以考虑将col2列放在一个二叉树的数据结构中，同样还是查询col2=23的记录，则只需要查询3次就可以查询到，效率要比没有索引的高得多。
- 但是二叉树也有弊端，如col1，如果我们把一个按照大小顺序排序的列数据存入二叉树中，我们发现，最终其实会以类似链表的形式进行存储，我们在查询col1=7发现还是需要查询7次，所以对于这种有序的数据，并没有有效的提高查询效率。

## 红黑树

- 红黑树是一种二叉平衡树，可以保证单边叶子节点不超过3，如果超过则会进行自平衡，如图，可以发现它避免了二叉树的弊端。
- 但是使用红黑树的话，无法保证树的高度，假如我们表中对应索引行有1000万条数据，那么索引树会有1000万个节点，那么树的高度就是2的n次方=10000万，树的高度会很高，查询效率仍然会受到限制；另外，对于红黑树，每次单边超过3时，都会自平衡，需要成本较高的维护。

## Hash表

### 特点：

对索引的key进行一次hash计算就可以定位出数据存储的位置

很多时候Hash索引要比B+ 树索引更高效

仅能满足 “=”，“IN”，不支持范围查询

hash冲突问题
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210628173402954.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MDI0Mzg5NA==,size_16,color_FFFFFF,t_70)

## B-Tree

B-Tree实际上解决了红黑树高度不可控的问题，B-Tree以数据页的方式存储数据，对于红黑树每个节点只能存储一个索引数据，B-Tree可以存储一页索引数据，每个数据页又可以分叉成n个数据页，这样，每个节点存储的索引数据多了，树的高度就降低了。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210628173424117.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MDI0Mzg5NA==,size_16,color_FFFFFF,t_70)

### 特点：

B-Tree
叶节点具有相同的深度，叶节点的指针为空
所有索引元素不重复
节点中的数据索引从左到右递增排列。

## B+Tree

### 特点：

非叶子节点不存储data，只存储索引(冗余)，可以放更多的索引
叶子节点包含所有索引字段
叶子节点用指针连接，提高区间访问的性能
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210628173443567.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MDI0Mzg5NA==,size_16,color_FFFFFF,t_70)

## 
