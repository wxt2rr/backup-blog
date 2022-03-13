---
hide: false
title: 使用ssh登录远程服务器报错
date: 2021-06-17 08:30:24
comments: true
toc: true
categories:
    - SSH
tags: 
    - ssh
---
今天使用ssh远程链接远程服务器时，突然报错了，记录一下原因
<!--more-->
![报错信息](https://img-blog.csdnimg.cn/20210605093631587.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MDI0Mzg5NA==,size_16,color_FFFFFF,t_70)

原因是我的远程服务器进行了重置，导致本地记录的验证信息过时了。

有两个办法可以解决：
* 删除本地验证信息，看图我们可以知道验证信息就是/Users/wangxiaotao/.ssh/known_hosts  的known_hosts文件；执行命令 rm -rf ./known_hosts将验证信息删除,或者将远程服务器对应的配置信息删除；
* 不想改动known_hosts文件的话，可以利用 ssh-keygen -R [远程机器ip]:port  这个命令来删掉关于特定的远程机器的host信息。
