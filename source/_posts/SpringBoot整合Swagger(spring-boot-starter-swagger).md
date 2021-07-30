---
hide: false
title: SpringBoot整合Swagger(spring-boot-starter-swagger)
date: 2020-09-15 09:25:00
summary: SpringBoot整合Swagger(spring-boot-starter-swagger)
categories: 接口文档服务
tags:
  - Swagger
  - springboot
  - 接口文档
---
﻿>我们在使用swagger时，需要配置config配置类，spring-boot-starter-swagger则利用Spring Boot的自动化配置特性来实现快速的将swagger2引入spring boot应用来生成API文档，简化原生使用swagger2的整合代码。

* [GitHub地址](https://github.com/SpringForAll/spring-boot-starter-swagger)

#### 一、引入pom
~~~ xml
<dependency>
	<groupId>com.spring4all</groupId>
	<artifactId>swagger-spring-boot-starter</artifactId>
	<version>1.9.1.RELEASE</version>
</dependency>
~~~
#### 二、项目启动类添加 @EnableSwagger2Doc
~~~java
@EnableSwagger2Doc
@SpringBootApplication
public class SpringbootSwaggerSpring4allApplication {

	public static void main(String[] args) {
		SpringApplication.run(SpringbootSwaggerSpring4allApplication.class, args);
	}

}
~~~
#### 三、在项目配置文件中配置参数
~~~ shell
# 是否启用swagger，默认：true
swagger.enabled=true
# 需要处理的基础URL规则，默认：/**
swagger.base-path=/**
# 扫描的基础包，默认：全扫描
swagger.base-package=com.wangxt.springbootswaggerspring4all.controller
# 标题
swagger.title=springboot-swagger-spring4all
# 描述
swagger.description=swagger-spring4all-demo
# 版本
swagger.version=2.9.2
# 维护人
swagger.contact.name=wangxt
# 维护人URL
swagger.contact.url=https://wangxt.online
# 维护人email
swagger.contact.email=1471520488@qq.com
~~~
#### 四、写个接口看看效果
##### Controller
~~~java
package com.wangxt.springbootswaggerspring4all.controller;

import com.wangxt.springbootswaggerspring4all.domain.po.DemoPo;
import com.wangxt.springbootswaggerspring4all.domain.response.ResponseInfo;
import com.wangxt.springbootswaggerspring4all.domain.vo.DemoVo;
import com.wangxt.springbootswaggerspring4all.service.DemoService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 *
 * 示例 controller
 * @author wangxt
 * @date 2021/7/30 10:11
 */
@Api(tags = "示例 controller")

@RestController
@RequestMapping("/demo/")
public class DemoController {

    @Autowired
    private DemoService demoService;

    /**
     *
     * 参数为普通参数示例方法
     * @author wangxt
     * @date 2021/7/30 10:53
     * @return ResponseInfo
     */
    @ApiOperation(value = "参数为普通参数示例方法")
    @GetMapping("demo")
    public ResponseInfo<DemoVo> demo(@ApiParam(name = "用户ID", required = true, example = "1") Integer userId){
        return demoService.demo(userId);
    }

    /**
     *
     * 参数为对象示例方法
     * @author wangxt
     * @date 2021/7/30 10:53
     * @return ResponseInfo
     */
    @ApiOperation(value = "参数为对象示例方法")
    @GetMapping("demo4Po")
    public ResponseInfo<DemoVo> demo4Po(@ApiParam(name = "参数", required = true) @RequestBody DemoPo demoPo){
        return demoService.demo4Po(demoPo);
    }
}

~~~
##### Po
~~~java
package com.wangxt.springbootswaggerspring4all.domain.po;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

/**
 *
 * 示例入参 Po
 * @author wangxt
 * @date 2021/7/30 10:43
 */
@ApiModel("示例 Po")
@Data
public class DemoPo {
    @ApiModelProperty(value = "用户ID", required = true, example = "1")
    private Integer userId;
}
~~~
##### Vo
~~~java
package com.wangxt.springbootswaggerspring4all.domain.vo;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 *
 * 示例 Vo
 * @author wangxt
 * @date 2021/7/30 10:33
 */
@ApiModel("示例 Vo")
@Data
public class DemoVo {

    @ApiModelProperty(value = "用户ID", required = true, example = "1")
    private Integer userId;
    @ApiModelProperty(value = "用户名", required = true, example = "wangxt")
    private String username;
    @ApiModelProperty(value = "网站", required = false, example = "wangxt.online")
    private String website;
    @ApiModelProperty(value = "年龄", required = false, example = "18", name = "userAge")
    private Integer age;
    @ApiModelProperty(value = "生日", required = false, example = "8888-88-88", dataType = "string")
    private LocalDateTime birthday;
    @ApiModelProperty(value = "朋友", required = false, example = "[\"A\",\"B\",\"C\"]")
    private List<String> friends;
}
~~~
#### 启动项目，访问页面
默认页面地址：http://{ip}:{port}/swagger-ui.html

[我的示例地址查看](http://gh9d59.natappfree.cc/swagger-ui.html)（地址是内网穿透到我本机的，大概率访问不通（斜眼笑））

##### 页面截图
![在这里插入图片描述](https://img-blog.csdnimg.cn/693c2b53044542a3a974088cd831c8b6.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MDI0Mzg5NA==,size_16,color_FFFFFF,t_70)
#### 示例项目源码
[点我查看](https://github.com/wxt1471520488/springboot-swagger-spring4all)
#### 总结
到此，springboot项目整合swagger就完成了，整体配置相对原生的swagger2确实简单一些，只需要填写配置文件的参数即可，使用起来没有太大差别。默认的页面主题还是有些不友好（个人感觉）可以自己找个好看的ui换上，下篇换主题。

#### 插曲
第一次启动项目时报错，报错日志
~~~java
java.lang.IllegalStateException: Failed to load ApplicationContext
Caused by: org.springframework.context.ApplicationContextException: Failed to start bean 'documentationPluginsBootstrapper'; nested exception is com.google.common.util.concurrent.ExecutionError: com.google.common.util.concurrent.ExecutionError: java.lang.NoClassDefFoundError: javax/validation/constraints/Min
Caused by: com.google.common.util.concurrent.ExecutionError: com.google.common.util.concurrent.ExecutionError: java.lang.NoClassDefFoundError: javax/validation/constraints/Min
Caused by: com.google.common.util.concurrent.ExecutionError: java.lang.NoClassDefFoundError: javax/validation/constraints/Min
Caused by: java.lang.NoClassDefFoundError: javax/validation/constraints/Min
Caused by: java.lang.ClassNotFoundException: javax.validation.constraints.Min
~~~
原因是swagger引用到了javax.validation包下的类，但是我新建的springboot项目并没有集成这个包，所以引下pom就行了
~~~xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-validation</artifactId>
</dependency>
~~~
