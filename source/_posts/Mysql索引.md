---
title: InnoDB几个索引数据结构的区别
date: 2020-09-10 13:25:00
summary: Innodb几个索引数据结构的区别
categories: Mysql
tags:
  - Mysql索引
  - InnoDB
  - 数据结构
---
# 索引的本质
索引是帮助Mysql高效获取数据的排好序的数据结构
# 索引数据结构
![image.png](https://cdn.nlark.com/yuque/0/2021/png/1666959/1619138196308-b8f6e511-790a-4b28-851c-93739c3ed469.png#clientId=u3731b124-35fe-4&from=paste&height=365&id=u1ac46fe4&margin=%5Bobject%20Object%5D&name=image.png&originHeight=365&originWidth=266&originalType=binary&size=57302&status=done&style=none&taskId=udfc93eb8-6560-483d-9650-00319da510e&width=266)
假如有如上一张表，如果想要查询col2=23的那行数据，如果没有索引或者不走索引的话，那么将要查询7次才会查询到，并且这7行数据在磁盘里并不是挨着存储的，查询效率会非常低。
## 二叉树
![image.png](https://cdn.nlark.com/yuque/0/2021/png/1666959/1619136210439-8f41db17-6202-46ee-997b-a8ddd61bbca5.png#clientId=u3731b124-35fe-4&from=paste&height=437&id=ZYBpj&margin=%5Bobject%20Object%5D&name=image.png&originHeight=437&originWidth=880&originalType=binary&size=156243&status=done&style=none&taskId=u33b06682-aa2b-45c4-9c83-43b9ee4603a&width=880)

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

![图片2.png](https://cdn.nlark.com/yuque/0/2021/png/1666959/1619138129561-66a03a79-13a8-47ba-8d39-c3dfc9aa8515.png#clientId=u3731b124-35fe-4&from=drop&id=u4e2856d2&margin=%5Bobject%20Object%5D&name=%E5%9B%BE%E7%89%872.png&originHeight=427&originWidth=759&originalType=binary&size=34674&status=done&style=none&taskId=u484a4321-7f29-4ad6-b3f0-a367f923fcc)
## B-Tree
B-Tree实际上解决了红黑树高度不可控的问题，B-Tree以数据页的方式存储数据，对于红黑树每个节点只能存储一个索引数据，B-Tree可以存储一页索引数据，每个数据页又可以分叉成n个数据页，这样，每个节点存储的索引数据多了，树的高度就降低了。
![图片3.png](https://cdn.nlark.com/yuque/0/2021/png/1666959/1619138114035-6ba399a1-35f5-4f9f-bb38-80fe714c9aba.png#clientId=u3731b124-35fe-4&from=drop&id=u6e681ff8&margin=%5Bobject%20Object%5D&name=%E5%9B%BE%E7%89%873.png&originHeight=284&originWidth=876&originalType=binary&size=26297&status=done&style=none&taskId=ub974410a-77c4-416e-95cf-4b5213e7e74)
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


![图片1.png](https://cdn.nlark.com/yuque/0/2021/png/1666959/1619138034093-ab401079-75ed-4a62-9160-07e11db80cd8.png#clientId=u3731b124-35fe-4&from=drop&id=u22a432a2&margin=%5Bobject%20Object%5D&name=%E5%9B%BE%E7%89%871.png&originHeight=436&originWidth=998&originalType=binary&size=45953&status=done&style=none&taskId=u71867fbb-cde1-4d9e-ae12-a4a8e76ffb1)
## 
