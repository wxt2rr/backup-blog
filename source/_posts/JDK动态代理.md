---
hide: false
title: JDK动态代理详解
description: JDK动态代理的源码，JDK动态代理为什么不能代理实现类，JDK动态代理为什么只能代理接口
keywords: JDK动态代理,JDK动态代理源码,JDK动态代理原理
date: 2021-09-08 09:25:00 
summary: 对于JDK代理实现的实现原理、源码解读和个人理解
categories: 设计模式
tags:
 - 设计模式
 - 源码
 - AOP
---

## 使用

创建接口

~~~java
public interface Father {
    void eat();
}
~~~

创建实现类

~~~ java
public class Son implements Father{

    @Override
    public void eat() {
        System.out.println("吃饭");
    }
}
~~~

测试

~~~java
public class ProxyTest {

    public static void main(String[] args) {
        ProxyTest test = new ProxyTest();
        test.jdkProxy();
    }

    private void jdkProxy(){
        Father son = new Son();
        
        Father proxySon = (Father) Proxy.newProxyInstance(son.getClass().getClassLoader(), son.getClass().getInterfaces(), new InvocationHandler() {
            @Override
            public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                System.out.println("做饭");

                Object invoke = method.invoke(son, args);

                System.out.println("洗碗");

                return invoke;
            }
        });

        proxySon.eat();
    }
~~~

输出结果

~~~java
做饭
吃饭
洗碗
~~~

如上，是一个使用JDK动态代理的简单例子，通过Proxy类的静态方法newProxyInstance可以生成目标类的代理类，这里有几个疑问：

* 为什么要使用实例对象的ClassLoader和Interfaces，使用其实例对象的行不行，使用类的行不行
* 为什么被代理类非要实现接口
* newProxyInstance返回的代理类是什么类型，强转成实现类（Father proxySon = (Son) Proxy.newProxyInstance(...)）会不会报错

我们带着这几个问题看看源码

## 源码

### java.lang.reflect.Proxy

```java
public static Object newProxyInstance(ClassLoader loader,
                                      Class<?>[] interfaces,
                                      InvocationHandler h)
    throws IllegalArgumentException
{
    Objects.requireNonNull(h);
    // 克隆被代理类的接口Class对象
    final Class<?>[] intfs = interfaces.clone();
    // 使用Java安全管理器校验程序，防止恶心代码
    final SecurityManager sm = System.getSecurityManager();
    if (sm != null) {
        checkProxyAccess(Reflection.getCallerClass(), loader, intfs);
    }

    /*
     * Look up or generate the designated proxy class.
     * 查找或生成指定的代理类。这里会使用缓存，缓存里没有就创建代理类，放放到缓存中
     * 接下来我们进入这个方法看看
     */
    Class<?> cl = getProxyClass0(loader, intfs);

    /*
     * Invoke its constructor with the designated invocation handler.
     * 使用指定的调用处理程序调用其构造函数。
     */
    try {
        if (sm != null) {
            checkNewProxyPermission(Reflection.getCallerClass(), cl);
        }

        // 获取代理类的构造器，这里会生成一个入参为InvocationHandler.class的构造器
        final Constructor<?> cons = cl.getConstructor(constructorParams);
        final InvocationHandler ih = h;
        if (!Modifier.isPublic(cl.getModifiers())) {
            AccessController.doPrivileged(new PrivilegedAction<Void>() {
                public Void run() {
                    cons.setAccessible(true);
                    return null;
                }
            });
        }
        // 通过反射使用构造方法（带有InvocationHandler入参的构造方法）创建代理类的实例对象
        return cons.newInstance(new Object[]{h});
    } catch (IllegalAccessException|InstantiationException e) {
        throw new InternalError(e.toString(), e);
    } catch (InvocationTargetException e) {
        Throwable t = e.getCause();
        if (t instanceof RuntimeException) {
            throw (RuntimeException) t;
        } else {
            throw new InternalError(t.toString(), t);
        }
    } catch (NoSuchMethodException e) {
        throw new InternalError(e.toString(), e);
    }
}
```

~~~java
private static Class<?> getProxyClass0(ClassLoader loader,
                                           Class<?>... interfaces) {
    	// 这里为什么是65535？
        if (interfaces.length > 65535) {
            throw new IllegalArgumentException("interface limit exceeded");
        }

        // If the proxy class defined by the given loader implementing
        // the given interfaces exists, this will simply return the cached copy;
        // otherwise, it will create the proxy class via the ProxyClassFactory
    	/**
    	* 如果给定加载器定义的代理类实现,给定的接口存在，这将简单地返回缓存的副本；否则，它将通过 ProxyClassFactory 创建代理类
    	* 在进入这个方法看看
		/
        return proxyClassCache.get(loader, interfaces);
    }
~~~
###  java.lang.reflect.WeakCache
~~~java
public V get(K key, P parameter) {
        Objects.requireNonNull(parameter);

        expungeStaleEntries();

        Object cacheKey = CacheKey.valueOf(key, refQueue);

        // lazily install the 2nd level valuesMap for the particular cacheKey
        ConcurrentMap<Object, Supplier<V>> valuesMap = map.get(cacheKey);
        if (valuesMap == null) {
            ConcurrentMap<Object, Supplier<V>> oldValuesMap
                = map.putIfAbsent(cacheKey,
                                  valuesMap = new ConcurrentHashMap<>());
            if (oldValuesMap != null) {
                valuesMap = oldValuesMap;
            }
        }

        // create subKey and retrieve the possible Supplier<V> stored by that
        // subKey from valuesMap
    	// 其它代码先不关注，这里的apply方法会调用$ProxyClassFactory的apply方法
        Object subKey = Objects.requireNonNull(subKeyFactory.apply(key, parameter));
        Supplier<V> supplier = valuesMap.get(subKey);
        Factory factory = null;

        ...
    }
~~~
###  java.lang.reflect.Proxy
~~~java
private static final class ProxyClassFactory
        implements BiFunction<ClassLoader, Class<?>[], Class<?>>
    {
        // prefix for all proxy class names
    	// 代理类名前缀
        private static final String proxyClassNamePrefix = "$Proxy";

        // next number to use for generation of unique proxy class names
        private static final AtomicLong nextUniqueNumber = new AtomicLong();

        @Override
        public Class<?> apply(ClassLoader loader, Class<?>[] interfaces) {

            Map<Class<?>, Boolean> interfaceSet = new IdentityHashMap<>(interfaces.length);
            for (Class<?> intf : interfaces) {
                /*
                 * Verify that the class loader resolves the name of this
                 * interface to the same Class object.
                 */
                Class<?> interfaceClass = null;
                try {
                    // 循环获取被代理类的接口结合的Class对象
                    interfaceClass = Class.forName(intf.getName(), false, loader);
                } catch (ClassNotFoundException e) {
                }
                if (interfaceClass != intf) {
                    throw new IllegalArgumentException(
                        intf + " is not visible from class loader");
                }
                /*
                 * Verify that the Class object actually represents an
                 * interface.
                 */
                if (!interfaceClass.isInterface()) {
                    throw new IllegalArgumentException(
                        interfaceClass.getName() + " is not an interface");
                }
                /*
                 * Verify that this interface is not a duplicate.
                 */
                if (interfaceSet.put(interfaceClass, Boolean.TRUE) != null) {
                    throw new IllegalArgumentException(
                        "repeated interface: " + interfaceClass.getName());
                }
            }

            String proxyPkg = null;     // package to define proxy class in
            int accessFlags = Modifier.PUBLIC | Modifier.FINAL;

            /*
             * Record the package of a non-public proxy interface so that the
             * proxy class will be defined in the same package.  Verify that
             * all non-public proxy interfaces are in the same package.
             */
            for (Class<?> intf : interfaces) {
                int flags = intf.getModifiers();
                if (!Modifier.isPublic(flags)) {
                    accessFlags = Modifier.FINAL;
                    String name = intf.getName();
                    int n = name.lastIndexOf('.');
                    String pkg = ((n == -1) ? "" : name.substring(0, n + 1));
                    if (proxyPkg == null) {
                        proxyPkg = pkg;
                    } else if (!pkg.equals(proxyPkg)) {
                        throw new IllegalArgumentException(
                            "non-public interfaces from different packages");
                    }
                }
            }

            if (proxyPkg == null) {
                // if no non-public proxy interfaces, use com.sun.proxy package
                proxyPkg = ReflectUtil.PROXY_PACKAGE + ".";
            }

            /*
             * Choose a name for the proxy class to generate.
             */
            long num = nextUniqueNumber.getAndIncrement();
            // com.sun.proxy.  +  $Proxy   + 0
            String proxyName = proxyPkg + proxyClassNamePrefix + num;

            /*
             * Generate the specified proxy class.
             * 生成指定的代理类文件，并判断是否需要持久化，这里只是普通的文件字节数组，jvm并不认识
             */
            byte[] proxyClassFile = ProxyGenerator.generateProxyClass(
                proxyName, interfaces, accessFlags);
            try {
                // 定义代理类，加载到jvm中，生成真正可以使用的运行时代理类的Class对象，
                return defineClass0(loader, proxyName,
                                    proxyClassFile, 0, proxyClassFile.length);
            } catch (ClassFormatError e) {
                /*
                 * A ClassFormatError here means that (barring bugs in the
                 * proxy class generation code) there was some other
                 * invalid aspect of the arguments supplied to the proxy
                 * class creation (such as virtual machine limitations
                 * exceeded).
                 */
                throw new IllegalArgumentException(e.toString());
            }
        }
    }
~~~

## 分析

byte[] proxyClassFile = ProxyGenerator.generateProxyClass(proxyName, interfaces, accessFlags);这块代码可以生成代理类的字节数组，那么我们是不是可以看看生成的代理类到底长什么样呢？写个测试方法看看

~~~java
private void write(){
        Father father = new Son();

        byte[] proxyArr = ProxyGenerator.generateProxyClass("$Proxy0", father.getClass().getInterfaces());

        try {
            Files.write(Paths.get("C:\\Users\\wxt\\Desktop\\test.class"), proxyArr);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
~~~

文件内容

~~~java
// 代理类默认继承了Proxy类，实现了被代理类的接口
public final class $Proxy0 extends Proxy implements Father {
    private static Method m1;
    private static Method m3;
    private static Method m2;
    private static Method m0;
    
    static {
        try {
            // 这里初始化4个成员变量
            m1 = Class.forName("java.lang.Object").getMethod("equals", Class.forName("java.lang.Object"));
            m3 = Class.forName("com.wangxt.wxt.design.patterns.proxy.dynamic.Father").getMethod("eat");
            m2 = Class.forName("java.lang.Object").getMethod("toString");
            m0 = Class.forName("java.lang.Object").getMethod("hashCode");
        } catch (NoSuchMethodException var2) {
            throw new NoSuchMethodError(var2.getMessage());
        } catch (ClassNotFoundException var3) {
            throw new NoClassDefFoundError(var3.getMessage());
        }
    }

    public $Proxy0(InvocationHandler var1) throws  {
        // 这里会调用父类的构造，并把InvocationHandler传递
        super(var1);
    }
    
    // 这里是我们自定义的方法，其它方法道理相同
    public final void eat() throws  {
        try {
            // 可以看到，当我们调用代理类的方法时，实际上会调用父类的h(InvocationHandler)的invoke方法
            // @Override
            // public Object invoke(Object proxy, Method method, Object[] args) throws Throwable
            // 所以我们重写InvocationHandler的invoke方法时传入的就是这几个参数
            super.h.invoke(this, m3, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }

    ...
}
~~~

好了，到这里基本信息都看完了，我们做个总结

* 准备代理类的描述数据

* 创建代理类（实现接口）的字节码文件
* 通过ClassLoader将代理类的字节数组加载到JVM中
* 创建代理类的实例对象，执行对象的目标方法

我们回过头来，在想想最开始的3个问题：

* 为什么要使用实例对象的ClassLoader和Interfaces，使用其实例对象的行不行，使用类的行不行
  * 因为我们要代理的接口是应用类加载器加载的，所以理论上只要应用类加载器加的类都可以
  * 但是interface肯定是需要实例对象(son.getClass())或者代理类(Son.class)，因为我们要对其的接口进行代理
* 为什么被代理类非要实现接口
  * 因为代理类已经继承了Proxy类，所以只能实现接口
* newProxyInstance返回的代理类是什么类型，强转成实现类（Father proxySon = (Son) Proxy.newProxyInstance(...)）会不会报错
  * 返回的是实现了接口继承了Proxy的代理类，所以强转成Son会报错

## 总结

![image](https://cdn.jsdelivr.net/gh/wxt1471520488/images@main/hexo/JDK动态代理/cd920125-6864-4d4c-a490-c216177facaf.png)
