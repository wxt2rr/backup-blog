---
hide: false
title: 数据库连接参数allowMultiQueries的作用
date: 2020-09-07 09:25:00
summary: 连接数据库时allowMultiQueries=true的作用
categories: 数据库
tags:
  - Mysql
  - 数据库
  - 日常踩坑
---

>~~~ mysql
> <delete id="delete">
>        <foreach collection="list" item="item" index="index" separator=";" >
>            delete from xxxx_table
>            where gid = #{item.gId} and pid = #{item.pId}
>        </foreach>
>    </delete>
>~~~
>
>
>
>如上，今天有个同事写了一条sql，先不管sql的业务逻辑和可用性，在本地执行没有问题，部署到QA环境报错，大概意思就是sql有问题，大概意思就是sql在where gid = #{item.gId} 执行有问题。
>
>##### 问题原因：
>
>本地数据库连接时设置了allowMultiQueries=true，但是QA环境没有设置，那默认是false。
>
>##### allowMultiQueries=true的作用
>
>* 可以在sql语句后携带分号，实现多语句执行。
>* 可以执行批处理，同时发出多个SQL语句。
>
>将QA环境的数据库连接加上这个属性就可以了。
