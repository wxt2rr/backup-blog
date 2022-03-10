---
hide: false
title: windows 批量启动软件脚本
date: 2020-09-08 10:25:00
summary: windows 批量启动软件脚本
categories: windows
tags:
  - bat
  - 脚本
  - 便捷开发
---

> 公司预备使用的是windows系统主机办公，每天早上来了第一件事就是开机，启动软件，启动软件，启动...，个人不太喜欢使用软件的开机自启动，于是有了这个脚本。

## 代码
~~~ shell
@echo off
title quick start
start /d "D:\software\WeChat\" WeChat.exe
echo starting weChat
choice /t 3 /d y /n >nul
start /d "D:\software\WXWork\" WXWork.exe
echo starting wxWork
choice /t 3 /d y /n >nul
start /d "D:\software\Clash for Windows\" Clash.exe
echo starting clash
choice /t 3 /d y /n >nul
echo start over bye~
~~~

## 使用

* 新建一个start.txt文件，修改文件后缀名为start.bat
* 右击软件，右击选择编辑，将代码复制过去
* 将代码中的路径和软件名称替换成你自己的

**注意**

软件名称不要有空格，否则会报错
