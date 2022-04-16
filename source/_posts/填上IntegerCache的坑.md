---
hide: false
title: 填上IntegerCache的坑
date: 2017-10-16 21:01:24
comments: true 
toc: true 
categories:
- Java基础
tags:
- Java
- Integer
- IntegerCache
---
初入职场时，确实被IntegerCache坑过一次，如下代码，本地跑程序都没问题，一到线上就不行，原因就是IntegerCache的问题，比较两个Integer时，本地数据少，数值也小，正好都是true，正式数据多，可能就因为IntegerCache的问题导致该是true的为false了，导致程序的执行出错。
<!--more-->

<<<<<<< HEAD
> 初入职场时，确实被IntegerCache坑过一次，如下代码，本地跑程序都没问题，一到线上就不行，原因就是IntegerCache的问题，比较两个Integer时，本地数据少，数值也小，正好都是true，正式数据多，可能就因为IntegerCache的问题导致该是true的为false了，导致程序的执行出错。

=======
>>>>>>> 6c17406bb8832309feff17463165b98c13ab74c7
  ```java
//......
Integer a = 200;
Integer b = 200;
if(a == b){
    //......
}
//......
  ```

我们直接看Integer类的源码：

```java
private static class IntegerCache {
        static final int low = -128;
        static final int high;
        static final Integer cache[];

        static {
            // high value may be configured by property
            int h = 127;
            String integerCacheHighPropValue =
                sun.misc.VM.getSavedProperty("java.lang.Integer.IntegerCache.high");
            if (integerCacheHighPropValue != null) {
                int i = parseInt(integerCacheHighPropValue);
                i = Math.max(i, 127);
                // Maximum array size is Integer.MAX_VALUE
                h = Math.min(i, Integer.MAX_VALUE - (-low) -1);
            }
            high = h;

            cache = new Integer[(high - low) + 1];
            int j = low;
            for(int k = 0; k < cache.length; k++)
                cache[k] = new Integer(j++);
        }

        private IntegerCache() {}
}
```

可以看到，Integer内部维护着IntegerCache的一个内部类，我们分析一下这个IntegerCache,它维护着两个静态int常量，和一个静态的Integer数组，然后静态块里初始化了high值和cache数组，并且将low到high中的数值add到了cache中，并且可以看到low值是常量-128,high值我们是可以通过配置文件配置的，也就是说我们可以根据jvm自行修改IntegerCache的阈值(
最大值)，只是看IntegerCache的话发现很简单，接下来我们结合Integer的几个方法在分析一下：

Integer的构造方法：

```java
public Integer(int value) {
        this.value = value;
}
```

Integer的parstInt方法：

```java
public static Integer valueOf(int i) {
        assert IntegerCache.high >= 127;
        if (i >= IntegerCache.low && i <= IntegerCache.high)
            return IntegerCache.cache[i + (-IntegerCache.low)];
        return new Integer(i);
}
```

Integer的parstInt方法：

```java
public static int parseInt(String s, int radix) throws NumberFormatException {
        /*
         * WARNING: This method may be invoked early during VM initialization
         * before IntegerCache is initialized. Care must be taken to not use
         * the valueOf method.
         */

        if (s == null) {
            throw new NumberFormatException("null");
        }

        if (radix < Character.MIN_RADIX) {
            throw new NumberFormatException("radix " + radix +
                                            " less than Character.MIN_RADIX");
        }

        if (radix > Character.MAX_RADIX) {
            throw new NumberFormatException("radix " + radix +
                                            " greater than Character.MAX_RADIX");
        }

        int result = 0;
        boolean negative = false;
        int i = 0, len = s.length();
        int limit = -Integer.MAX_VALUE;
        int multmin;
        int digit;

        if (len > 0) {
            char firstChar = s.charAt(0);
            if (firstChar < '0') { // Possible leading "+" or "-"
                if (firstChar == '-') {
                    negative = true;
                    limit = Integer.MIN_VALUE;
                } else if (firstChar != '+')
                    throw NumberFormatException.forInputString(s);

                if (len == 1) // Cannot have lone "+" or "-"
                    throw NumberFormatException.forInputString(s);
                i++;
            }
            multmin = limit / radix;
            while (i < len) {
                // Accumulating negatively avoids surprises near MAX_VALUE
                digit = Character.digit(s.charAt(i++),radix);
                if (digit < 0) {
                    throw NumberFormatException.forInputString(s);
                }
                if (result < multmin) {
                    throw NumberFormatException.forInputString(s);
                }
                result *= radix;
                if (result < limit + digit) {
                    throw NumberFormatException.forInputString(s);
                }
                result -= digit;
            }
        } else {
            throw NumberFormatException.forInputString(s);
        }
        return negative ? result : -result;
}
```

可以看到，通过Integer的构造方法创建Integer对象时，并不会跟IntegerCache扯上关系，也就是说创建多少个都是新对象，比较的话都是false，因为他们的地址值都不一样；parseInt方法返回的是int基本类型，所以跟IntegerCache也没有关系；我们再来看一下valueOf方法，在给定的IntegerCache的阈值范围内，Integer对象都是从cache数组中取到的，而内部类都是懒加载，在使用时加载内部类，并且创建阈值之内的所有Integer对象并存入cache中，cache是静态常量数组，由常量池维护着，cache被所有的Integer对象共享，所以只要是比较cache阈值之内的两个Integer的结果都是true，因为本身他们就是同一个对象。(
ps:Integer a = 1; 默认调用的是valueOf方法)。

到此为止，我们应该对IntegerCache有了一定的了解，那么做点习题巩固一下：

```java
Integer x = 1;
Integer y = 1;
System.out.println(String.format("1:%s",x == y));// 1
x = 127;
y = 127;
System.out.println(String.format("2:%s",x == y));// 2
x = 128;
y = 128;
System.out.println(String.format("3:%s",x == y));// 3
x = new Integer(1);
y = new Integer(1);
System.out.println(String.format("4:%s",x == y));// 4
x = Integer.parseInt("127");
y = Integer.parseInt("127");
System.out.println(String.format("5:%s",x == y));// 5
x = Integer.parseInt("128");
y = Integer.parseInt("128");
System.out.println(String.format("6:%s",x == y));// 6
x = new Integer(1);
System.out.println(String.format("7:%s",x == y));// 7
x = new Integer(128);
System.out.println(String.format("8:%s",x == y));// 8
```

结果：

1:true 2:true 3:false 4:false 5:true 6:false 7:false 8:false

如果你都做对了，那么你对IntegerCache已经算是过关了，^_^！！！这里在说一下x = Integer.parseInt("127")和y = Integer.parseInt("127")这两个比较，因为parstInt()
方法返回的是int基本类型,自动装箱，就变成了Integer x = 127;调用valueOf方法,所以判断结果和直接调用valueOf方法是一样的。

续：下边输出结果是什么

```java
    @Test
    public void test() {
        Integer x = 1;
        Integer y = 1;
        System.out.println(x.equals(y));
    }
```

上边x和y都是各自创建了一个新的Integer对象，两个引用对象去equals的话，一般是比较地址值，返回应该是false，但是像Integer和String这种类，都重写了equals方法，Integer的equals实际就是两个int基本类型的值比较，所以返回的是true。如下：

```java
    /**
     * Compares this object to the specified object.  The result is
     * {@code true} if and only if the argument is not
     * {@code null} and is an {@code Integer} object that
     * contains the same {@code int} value as this object.
     *
     * @param   obj   the object to compare with.
     * @return  {@code true} if the objects are the same;
     *          {@code false} otherwise.
     */
    public boolean equals(Object obj) {
        if (obj instanceof Integer) {
            return value == ((Integer)obj).intValue();
        }
        return false;
    }
```

另外，除了Integer，向Long、Double等包装类，都有缓存区的操作，所以在使用两个包装类进行相等判断时需要注意，最好使用equals方法，引用类判断是否相等就应该使用equals方法，然后重写equals实现我们想要的相等规则。使用包装类型和基本类型做判断则不需要，会自动拆箱。
