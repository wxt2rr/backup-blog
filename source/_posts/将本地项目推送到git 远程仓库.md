---
<<<<<<< HEAD
hide: false title: 将本地项目推送到git 远程仓库 date: 2020-05-11 12:30:00 categories: GIT tags:

- git
- ssh

=======
hide: false
title: 将本地项目推送到git 远程仓库
date: 2017-05-11 12:30:00
categories: GIT
tags:
  - git
  - ssh
>>>>>>> 6c17406bb8832309feff17463165b98c13ab74c7
---
将本地项目推送到 git远程仓库，就是想记录一下
<!--more-->
### 将本地项目推送到git 远程仓库

> ```shell
> # 初始化本地文件夹，加入git控制
> git init
> # 将文件 添加到git 暂存区
> git add .
> # 将文件提交到本地仓库
> git commit -m "first commit"
> # 创建一个名字为’main‘的远程分支
> git branch -M main
> # 绑定本地仓库和远程仓库
> git remote add origin git@github.com:wxt1471520488/my-blog.git
> # 将本地仓库的文件改动推动到远程仓库
> git push origin main
> ```

