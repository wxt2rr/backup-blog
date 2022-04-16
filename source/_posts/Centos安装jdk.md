---
hide: false
title: Cent os 安装jdk date: 2020-09-07 09:25:00 
summary: 整理一下cent os安装jdk的方式 
categories: CentOs 
tags:
 - jdk
 - centos

---

### 手动安装

#### 创建安装目录

```sh
[root@iZ8vb7tm9o88h6ioml28vsZ usr]# cd /usr
[root@iZ8vb7tm9o88h6ioml28vsZ usr]# mkdir java
[root@iZ8vb7tm9o88h6ioml28vsZ usr]# cd java
```

#### 下载jdk 源码包

> [Oracle 官网地址](https://www.oracle.com/java/technologies/javase-downloads.html)

下载之后上传到服务器

如果感觉麻烦的话，也可以使用wget

> 直接使用下载链接获取到的tar包是有问题的，oracle对链接进行了授权校验：wget https://download.oracle.com/otn/java/jdk/8u291-b10/d7fc238d0cbf4b0dac67be84580cfb4b/jdk-8u291-linux-x64.tar.gz

我们需要在下载链接之前加上 --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F;
oraclelicense=accept-securebackup-cookie" ，如:

```sh
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "https://download.oracle.com/otn/java/jdk/8u291-b10/d7fc238d0cbf4b0dac67be84580cfb4b/jdk-8u291-linux-x64.tar.gz"
```

#### 解压

```sh
# 解压包
[root@iZ8vb7tm9o88h6ioml28vsZ java]# tar -zxvf jdk-8u141-linux-x64.tar.gz
# 解压完之后会生成一个 jdk1.8.0_141 的文件夹
[root@iZ8vb7tm9o88h6ioml28vsZ java]# ls
jdk1.8.0_141  jdk-8u141-linux-x64.tar.gz
[root@iZ8vb7tm9o88h6ioml28vsZ java]# cd jdk1.8.0_141/
# 获取当前文件夹得绝对路径，配置环境变量时会用
[root@iZ8vb7tm9o88h6ioml28vsZ jdk1.8.0_141]# pwd
/usr/java/java/jdk1.8.0_141
```

#### 配置环境变量

```sh
vim /etc/profile

在文件最后加上
# java
export JAVA_HOME=/usr/java/java/jdk1.8.0_141 #上步 pwd 命令获取到的路径
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib
```

#### 验证

```sh
# 使 profile 修改生效
[root@iZ8vb7tm9o88h6ioml28vsZ java]# source /etc/profile
# 验证结果
[root@iZ8vb7tm9o88h6ioml28vsZ java]# java -version
java version "1.8.0_291"
Java(TM) SE Runtime Environment (build 1.8.0_291-b10)
Java HotSpot(TM) 64-Bit Server VM (build 25.291-b10, mixed mode)
```

### yum安装

```sh
# 搜索可用的jdk安装包
[root@iZ8vb7tm9o88h6ioml28vsZ java]# yum search java|grep jdk
ldapjdk-javadoc.noarch : Javadoc for ldapjdk
java-1.6.0-openjdk.x86_64 : OpenJDK Runtime Environment
java-1.6.0-openjdk-demo.x86_64 : OpenJDK Demos
java-1.6.0-openjdk-devel.x86_64 : OpenJDK Development Environment
java-1.6.0-openjdk-javadoc.x86_64 : OpenJDK API Documentation
java-1.6.0-openjdk-src.x86_64 : OpenJDK Source Bundle
java-1.7.0-openjdk.x86_64 : OpenJDK Runtime Environment
java-1.7.0-openjdk-accessibility.x86_64 : OpenJDK accessibility connector
java-1.7.0-openjdk-demo.x86_64 : OpenJDK Demos
java-1.7.0-openjdk-devel.x86_64 : OpenJDK Development Environment
java-1.7.0-openjdk-headless.x86_64 : The OpenJDK runtime environment without
java-1.7.0-openjdk-javadoc.noarch : OpenJDK API Documentation
java-1.7.0-openjdk-src.x86_64 : OpenJDK Source Bundle
java-1.8.0-openjdk.i686 : OpenJDK Runtime Environment 8
java-1.8.0-openjdk.x86_64 : OpenJDK 8 Runtime Environment
java-1.8.0-openjdk-accessibility.i686 : OpenJDK accessibility connector
java-1.8.0-openjdk-accessibility.x86_64 : OpenJDK accessibility connector
java-1.8.0-openjdk-demo.i686 : OpenJDK Demos 8
java-1.8.0-openjdk-demo.x86_64 : OpenJDK 8 Demos
java-1.8.0-openjdk-devel.i686 : OpenJDK Development Environment 8
java-1.8.0-openjdk-devel.x86_64 : OpenJDK 8 Development Environment
java-1.8.0-openjdk-headless.i686 : OpenJDK Headless Runtime Environment 8
java-1.8.0-openjdk-headless.x86_64 : OpenJDK 8 Headless Runtime Environment
java-1.8.0-openjdk-javadoc.noarch : OpenJDK 8 API documentation
java-1.8.0-openjdk-javadoc-zip.noarch : OpenJDK 8 API documentation compressed
java-1.8.0-openjdk-src.i686 : OpenJDK Source Bundle 8
java-1.8.0-openjdk-src.x86_64 : OpenJDK 8 Source Bundle
java-11-openjdk.i686 : OpenJDK Runtime Environment 11
java-11-openjdk.x86_64 : OpenJDK 11 Runtime Environment
java-11-openjdk-demo.i686 : OpenJDK Demos 11
java-11-openjdk-demo.x86_64 : OpenJDK 11 Demos
java-11-openjdk-devel.i686 : OpenJDK Development Environment 11
java-11-openjdk-devel.x86_64 : OpenJDK 11 Development Environment
java-11-openjdk-headless.i686 : OpenJDK Headless Runtime Environment 11
java-11-openjdk-headless.x86_64 : OpenJDK 11 Headless Runtime Environment
java-11-openjdk-javadoc.i686 : OpenJDK 11 API documentation
java-11-openjdk-javadoc.x86_64 : OpenJDK 11 API documentation
java-11-openjdk-javadoc-zip.i686 : OpenJDK 11 API documentation compressed in a
java-11-openjdk-javadoc-zip.x86_64 : OpenJDK 11 API documentation compressed in
java-11-openjdk-jmods.i686 : JMods for OpenJDK 11
java-11-openjdk-jmods.x86_64 : JMods for OpenJDK 11
java-11-openjdk-src.i686 : OpenJDK Source Bundle 11
java-11-openjdk-src.x86_64 : OpenJDK 11 Source Bundle
java-11-openjdk-static-libs.i686 : OpenJDK libraries for static linking 11
java-11-openjdk-static-libs.x86_64 : OpenJDK 11 libraries for static linking
java-latest-openjdk.x86_64 : OpenJDK 16 Runtime Environment
java-latest-openjdk-debug.x86_64 : OpenJDK 16 Runtime Environment with full
java-latest-openjdk-demo.x86_64 : OpenJDK 16 Demos
java-latest-openjdk-demo-debug.x86_64 : OpenJDK 16 Demos with full debugging on
java-latest-openjdk-demo-fastdebug.x86_64 : OpenJDK 16 Demos with minimal
java-latest-openjdk-devel.x86_64 : OpenJDK 16 Development Environment
java-latest-openjdk-devel-debug.x86_64 : OpenJDK 16 Development Environment with
java-latest-openjdk-devel-fastdebug.x86_64 : OpenJDK 16 Development Environment
java-latest-openjdk-fastdebug.x86_64 : OpenJDK 16 Runtime Environment with
java-latest-openjdk-headless.x86_64 : OpenJDK 16 Headless Runtime Environment
java-latest-openjdk-headless-debug.x86_64 : OpenJDK 16 Runtime Environment with
java-latest-openjdk-headless-fastdebug.x86_64 : OpenJDK 16 Runtime Environment
java-latest-openjdk-javadoc.x86_64 : OpenJDK 16 API documentation
java-latest-openjdk-javadoc-zip.x86_64 : OpenJDK 16 API documentation compressed
java-latest-openjdk-jmods.x86_64 : JMods for OpenJDK 16
java-latest-openjdk-jmods-debug.x86_64 : JMods for OpenJDK 16 with full
java-latest-openjdk-jmods-fastdebug.x86_64 : JMods for OpenJDK 16 with minimal
java-latest-openjdk-src.x86_64 : OpenJDK 16 Source Bundle
java-latest-openjdk-src-debug.x86_64 : OpenJDK 16 Source Bundle for packages
java-latest-openjdk-src-fastdebug.x86_64 : OpenJDK 16 Source Bundle
java-latest-openjdk-static-libs.x86_64 : OpenJDK 16 libraries for static linking
java-latest-openjdk-static-libs-debug.x86_64 : OpenJDK 16 libraries for static
java-latest-openjdk-static-libs-fastdebug.x86_64 : OpenJDK 16 libraries for
ldapjdk.noarch : The Mozilla LDAP Java SDK
# 安装
[root@iZ8vb7tm9o88h6ioml28vsZ java]# yum install java-1.8.0-openjdk
# 默认安装在 /usr/lib/jvm 下
[root@iZ8vb7tm9o88h6ioml28vsZ jvm]# cd /usr/lib/jvm/
[root@iZ8vb7tm9o88h6ioml28vsZ jvm]# ls -l
total 4
drwxr-xr-x 3 root root 4096 Jun 20 18:33 java-1.8.0-openjdk-1.8.0.292.b10-1.el7_9.x86_64
lrwxrwxrwx 1 root root   21 Jun 20 18:33 jre -> /etc/alternatives/jre
lrwxrwxrwx 1 root root   27 Jun 20 18:33 jre-1.8.0 -> /etc/alternatives/jre_1.8.0
lrwxrwxrwx 1 root root   35 Jun 20 18:33 jre-1.8.0-openjdk -> /etc/alternatives/jre_1.8.0_openjdk
lrwxrwxrwx 1 root root   51 Jun 20 18:33 jre-1.8.0-openjdk-1.8.0.292.b10-1.el7_9.x86_64 -> java-1.8.0-openjdk-1.8.0.292.b10-1.el7_9.x86_64/jre
lrwxrwxrwx 1 root root   29 Jun 20 18:33 jre-openjdk -> /etc/alternatives/jre_openjdk
```

安装完之后同样配置环境变量，验证结果。
