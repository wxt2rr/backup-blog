---
hide: false title: 给前端返回long类型造成精度损失 date: 2021-11-07 09:25:00 summary: 连接数据库时allowMultiQueries=true的作用 categories: 踩坑系列
tags:

- js
- 日常踩坑

---
今天同事遇到一个问题，后端给前端返回一个long类型的参数，前端获取到时候造成了精度损失，记录一下
<!-- more -->

### 原因

JS的基础类型Number，遵循 [IEEE 754](https://en.wikipedia.org/wiki/IEEE_floating_point) 规范，采用双精度存储（double precision），占用 64 bit。如图

![img](https://images2015.cnblogs.com/blog/114013/201511/114013-20151106171603555-975142832.png)

意义

- 1位用来表示符号位
- 11位用来表示指数
- 52位表示尾数

浮点数，比如

```
`0.1 >> 0.0001 1001 1001 1001…（1001无限循环）``0.2 >> 0.0011 0011 0011 0011…（0011无限循环）`
```

此时只能模仿十进制进行四舍五入了，但是二进制只有 0 和 1 两个，于是变为 0 舍 1 入。这即是计算机中部分浮点数运算时出现误差，丢失精度的根本原因。

大整数的精度丢失和浮点数本质上是一样的，尾数位最大是 52 位，因此 JS 中能精准表示的最大整数是 Math.pow(2, 53)，十进制即 9007199254740992。

大于 9007199254740992 的可能会丢失精度

### 解决办法

#### 1、使用ToStringSerializer的注解，让系统序列化

时，保留相关精度

```java
@JsonSerialize(using=ToStringSerializer.class)
private Long createdBy;


FastJson 注解
@JSONField(serializeUsing= ToStringSerializer.class)
```

> 上述方法需要在每个对象都配上该注解，此方法过于繁锁。

#### 2、使用全局配置，将转换时实现自动ToStringSerializer序列化

```java
Override
public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
    MappingJackson2HttpMessageConverter jackson2HttpMessageConverter = new MappingJackson2HttpMessageConverter();

    ObjectMapper objectMapper = new ObjectMapper();
    /**
     * 序列换成json时,将所有的long变成string
     * 因为js中得数字类型不能包含所有的java long值
     */
    SimpleModule simpleModule = new SimpleModule();
    simpleModule.addSerializer(Long.class, ToStringSerializer.instance);
    simpleModule.addSerializer(Long.TYPE, ToStringSerializer.instance);
    objectMapper.registerModule(simpleModule);

    jackson2HttpMessageConverter.setObjectMapper(objectMapper);
    converters.add(jackson2HttpMessageConverter);
```

> 项目中很多时候都会用到json，常用的有fastjson，Jackson等等这些，有时候为了统一，我们通常就会约定使用某一种。当然，有时候项目中也可能会统一约定使用了fastjson，然而Spring MVC中默认是使用了Jackson的

在Spring Boot中将Jackson替换为fastjson一般会有两种方式：

第一种：

```java
@Configuration
public class WebConfig extends WebMvcConfigurerAdapter {

    @Bean
    public HttpMessageConverters fastJsonHttpMessageConverter() {
        return new HttpMessageConverters(new FastJsonHttpMessageConverter());
    }
}
```

第二种：

```java
@Configuration
public class WebConfig extends WebMvcConfigurerAdapter {

    @Override
    public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
        FastJsonHttpMessageConverter fastConverter = 
        new FastJsonHttpMessageConverter();

        FastJsonConfig fastJsonConfig = new FastJsonConfig();
        fastJsonConfig.setSerializerFeatures(SerializerFeature.PrettyFormat);
        fastConverter.setFastJsonConfig(fastJsonConfig);
        converters.add(fastConverter);
    }
}
```

替换成fastjson之后，对于精度丢失问题，我们可以这么去做：

```java
@Configuration
public class WebConfig extends WebMvcConfigurerAdapter {

    @Override
    public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
        FastJsonHttpMessageConverter fastConverter = 
        new FastJsonHttpMessageConverter();

        FastJsonConfig fastJsonConfig = new FastJsonConfig();
        SerializeConfig serializeConfig = SerializeConfig.globalInstance;
        serializeConfig.put(BigInteger.class, ToStringSerializer.instance);
        serializeConfig.put(Long.class, ToStringSerializer.instance);
        serializeConfig.put(Long.TYPE, ToStringSerializer.instance);
        fastJsonConfig.setSerializeConfig(serializeConfig);
        fastConverter.setFastJsonConfig(fastJsonConfig);
        converters.add(fastConverter);
    }
}
```

### 总结

吃一堑长一智，需要精度准确的比如浮点数或者长整形最好给前端返回string类型
