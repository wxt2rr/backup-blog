---
hide: false
title: 【踩坑系列】Arrays$asList()抛UnsupportedOperationException异常
date: 2020-11-04 22:25:00
summary: 【踩坑系列】Arrays$asList()抛UnsupportedOperationException异常
categories: 踩坑系列
tags:
  - Arrays
  - 视图
  - 踩坑
---

> 今天写代码时遇到一个很奇怪的问题，我很主观的利用Arrays,asList()方法返回一个List，然后对该List进行了add()方法的调用，结果竟然抛了异常。

**示例代码：**
~~~java
@org.junit.Test
public void test(){
    List<String> list = Arrays.asList("aa","bb");
    boolean cc = list.add("cc");

    System.out.println(list);
}
~~~
**报错如下：**
~~~java
java.lang.UnsupportedOperationException
	at java.util.AbstractList.add(AbstractList.java:148)
	at java.util.AbstractList.add(AbstractList.java:108)
	at com.chuangkit.design.center.assist.impl.Test.test(Test.java:19)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:498)
	at org.junit.runners.model.FrameworkMethod$1.runReflectiveCall(FrameworkMethod.java:50)
	at org.junit.internal.runners.model.ReflectiveCallable.run(ReflectiveCallable.java:12)
	at org.junit.runners.model.FrameworkMethod.invokeExplosively(FrameworkMethod.java:47)
	at org.junit.internal.runners.statements.InvokeMethod.evaluate(InvokeMethod.java:17)
	at org.junit.runners.ParentRunner.runLeaf(ParentRunner.java:325)
	at org.junit.runners.BlockJUnit4ClassRunner.runChild(BlockJUnit4ClassRunner.java:78)
	at org.junit.runners.BlockJUnit4ClassRunner.runChild(BlockJUnit4ClassRunner.java:57)
	at org.junit.runners.ParentRunner$3.run(ParentRunner.java:290)
	at org.junit.runners.ParentRunner$1.schedule(ParentRunner.java:71)
	at org.junit.runners.ParentRunner.runChildren(ParentRunner.java:288)
	at org.junit.runners.ParentRunner.access$000(ParentRunner.java:58)
	at org.junit.runners.ParentRunner$2.evaluate(ParentRunner.java:268)
	at org.junit.runners.ParentRunner.run(ParentRunner.java:363)
	at org.junit.runner.JUnitCore.run(JUnitCore.java:137)
	at com.intellij.junit4.JUnit4IdeaTestRunner.startRunnerWithArgs(JUnit4IdeaTestRunner.java:69)
	at com.intellij.rt.junit.IdeaTestRunner$Repeater.startRunnerWithArgs(IdeaTestRunner.java:33)
	at com.intellij.rt.junit.JUnitStarter.prepareStreamsAndStart(JUnitStarter.java:221)
	at com.intellij.rt.junit.JUnitStarter.main(JUnitStarter.java:54)
~~~
####  1.接下来我们看下源码，排查异常产生的原因
我们点进asList()方法看下源码是怎么实现的。
~~~java
@SafeVarargs
@SuppressWarnings("varargs")
public static <T> List<T> asList(T... a) {
    return new ArrayList<>(a);
}
~~~
这里发现这不是返回的就是一个new出来的ArrayList集合对象吗，没有什么问题啊，别着急，我们在进到ArrayList看看猫腻。
~~~java
/**
     * @serial include
     */
    private static class ArrayList<E> extends AbstractList<E>
        implements RandomAccess, java.io.Serializable
    {
        private static final long serialVersionUID = -2764017481108945198L;
        private final E[] a;

        ArrayList(E[] array) {
            a = Objects.requireNonNull(array);
        }

        @Override
        public int size() {
            return a.length;
        }

        @Override
        public Object[] toArray() {
            return a.clone();
        }

        @Override
        @SuppressWarnings("unchecked")
        public <T> T[] toArray(T[] a) {
            int size = size();
            if (a.length < size)
                return Arrays.copyOf(this.a, size,
                                     (Class<? extends T[]>) a.getClass());
            System.arraycopy(this.a, 0, a, 0, size);
            if (a.length > size)
                a[size] = null;
            return a;
        }

        @Override
        public E get(int index) {
            return a[index];
        }

        @Override
        public E set(int index, E element) {
            E oldValue = a[index];
            a[index] = element;
            return oldValue;
        }

        @Override
        public int indexOf(Object o) {
            E[] a = this.a;
            if (o == null) {
                for (int i = 0; i < a.length; i++)
                    if (a[i] == null)
                        return i;
            } else {
                for (int i = 0; i < a.length; i++)
                    if (o.equals(a[i]))
                        return i;
            }
            return -1;
        }

        @Override
        public boolean contains(Object o) {
            return indexOf(o) != -1;
        }

        @Override
        public Spliterator<E> spliterator() {
            return Spliterators.spliterator(a, Spliterator.ORDERED);
        }

        @Override
        public void forEach(Consumer<? super E> action) {
            Objects.requireNonNull(action);
            for (E e : a) {
                action.accept(e);
            }
        }

        @Override
        public void replaceAll(UnaryOperator<E> operator) {
            Objects.requireNonNull(operator);
            E[] a = this.a;
            for (int i = 0; i < a.length; i++) {
                a[i] = operator.apply(a[i]);
            }
        }

        @Override
        public void sort(Comparator<? super E> c) {
            Arrays.sort(a, c);
        }
    }
~~~
这时我们发现，此ArrayList并不是我们常用的java.util包下的，而是Arrays类自己实现的一个静态内部类，该内部类继承了AbstractList抽象类，我们知道AbstractList是实现了List接口的，而AbstractList本身也是一个抽象类，并没有对add等方法进行实现，Arrays$ArrayList虽然继承了AbstractList，但是也没有对add等方法进行实现，所以当我们调用该内部类的add方法时就抛出UnsupportedOperationException异常。
~~~java
// 1.首先我们看ArrayList继承了AbstractList
private static class ArrayList<E> extends AbstractList<E>
        implements RandomAccess, java.io.Serializable
    {

// 2.然后AbstractList又实现了List接口
public abstract class AbstractList<E> extends AbstractCollection<E> 
		implements List<E> 
	{

// 3.在List的add方法注释上可以看到如果实现类没有实现add方法就会抛异常
/**
  * ...
  * @throws UnsupportedOperationException if the {@code add} operation
  *         is not supported by this list
  * ...
  */
public boolean add(E e) {
    add(size(), e);
    return true;
}
~~~
#### 2.问题我们找到了，接下来我们想一想为什么Arrays要自己实现一个ArrayList呢
我们先看下源码注释是怎么说的（摘自于asList方法注释）
~~~java
/**
  * Returns a fixed-size list backed by the specified array.  (Changes to
  * the returned list "write through" to the array.)  This method acts
  * as bridge between array-based and collection-based APIs, in
  * combination with {@link Collection#toArray}.  The returned list is
  * serializable and implements {@link RandomAccess}.
  *
  * <p>This method also provides a convenient way to create a fixed-size
  * list initialized to contain several elements:
  * ...
  * 返回由指定数组支持的固定大小列表。（更改返回的列表“直写”到数组。）
  * 此方法与 {@link Collection#toArray} 结合，充当基于数组和基于集合的 API 之间的桥梁。
  * 返回的列表是可序列化的并实现了 {@link RandomAccess}。此方法还提供了一种创建固定大小列表
  * 的便捷方法，该列表已初始化为包含多个元素。
  * ...
  * @return a list view of the specified array
  * 指定数组的列表视图
  */
~~~
* **asList方法返回的是当前数组的的列表视图**，当我们改变原始数组的数据时，这个"视图"会自然而然的同步改变，因为它就是当前数组的一个展现形式，如果返回的是java.util包下的ArrayList，无疑会创建一个新的数组来代替当前数组，并且我们新的数据进行修改，原数组的数据也不会发生改变。
* **asList方法返回的是一个固定大小列表**，也就是说只要数组创建了，我们无法向数组中添加新的元素，只能对现有元素进行替换和查找，并且不能删除元素。这个java.util包下的ArrayList也是无法做到的。
* **此方法充当基于数组的API和基于集合的API之间的桥梁**，这句话也体现了，asList方法本身就不是一个真正意义上的集合方法，只是在基于两者的API基础上做了一个衔接。
#### 3.总结
Arrays$asList()本身并没有创建和返回一个新的集合对象，返回的仍然是描述原数组的视图，也就是该"集合"只满足对数组的操作，一但声明集合大小不能修改、不能直接删除某个元素等等；也就是说当我们通过asList方法将数组转成集合之后，我们对该集合的操作仅仅满足于对一个数组的操作，那么我们是可以使用这个方法的，如果想要得到的集合满足于一个真实集合对象的使用，那么这个方法是不适用的，我们这时候需要将数组复制到一个新的数组支持集合的创建，比如
~~~java
@org.junit.Test
public void test(){
    List<String> list = Arrays.asList("aa","bb");

    List<String> temp = new ArrayList<>(list);
    temp.add("cc");

    System.out.println(temp);
}
~~~
