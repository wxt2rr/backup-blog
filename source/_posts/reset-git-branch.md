---
hide: false
title: 一键重置git分支脚本
date: 2021-08-02 09:25:00
summary: 一键重置git分支脚本
categories: Shell
tags:
  - shell
  - git branch
---
> 由于公司的上线封版机制，每个上线窗口结束之后，需要将qa和develop分支切换成上个窗口的beta灰度分支，虽然逻辑很简单，但是处理起来还有有点小繁琐，所以写了一个脚本干这个事，其实就是将用到的git命令打包，叫脚本去执行了自己本该执行的git命令，简单记录一下
<!--more-->
~~~sh
#!/usr/bin/env bash
if [ $# -le 3 ]
  then
    echo "参数有误({源分支},{重置分支},{本地项目根目录},{项目名称(api/www)}) 举例："
	echo "8.29.1.0 qa D:/wangxt-git api"
    exit
fi
if [ -z $2 ]
  then
    LIST=(qa,develop)
  else
    LIST=($2)
fi
if [ -z $3 ]
  then
    WORK_PATH=D:/wangxt-git
  else
    WORK_PATH=$3
fi
if [ "api" = $4 ]
  then
    P_NAME=/api
	F_NAME=/framework
  else
    P_NAME=/www
	F_NAME=/framework
fi
echo "==============================================================="
echo "=     项目名称:         "$P_NAME"             "
echo "=                       "$F_NAME"             "
echo "=     源分支:           "$1"                  "
echo "=     要重置的分支:     "$LIST"               "
echo "=     你的项目绝对路径: "$3"                  "
echo "==============================================================="
echo "以上信息，确定正确码？请输入序号"
select yn in "正确,开始执行" "错误,退出程序"; do
   case $yn in
       正确,开始执行 ) 
	   echo "!!!!准备进入"$3"目录"
		cd WORK_PATH
		echo "当前工作目录："`pwd`
		echo "-------- api-framework 开始 -------"
		cd $WORK_PATH$F_NAME
		echo "当前工作目录："`pwd`
		git checkout -b $1.temp4shell remotes/origin/$1
			for i in $LIST
			do   
				echo "!!!!尝试删除本地分支："$i
				git checkout -b $1.temp4shell
				git pull
				git branch -D $i
				echo "!!!!忽略上边报错"
				git checkout -b $i remotes/origin/$i
				echo "!!!!重新检出分支："$i
				git branch -D $i
				git push origin --Delete $i
				echo "!!!! "$i" 分支删除完毕"
				git checkout -b $1 remotes/origin/$1
				git pull
				git checkout -b $i
				git push -u origin $i
				echo "!!!! "$i" 分支已从 "$1" 分支检出" 
			done
		git branch -D $1.temp4shell
		git push origin --Delete $1.temp4shell
		echo "------- api-framework 结束 -------"
		echo "================================="
		echo "--------- api 开始 ---------"
		cd $WORK_PATH$P_NAME
		echo "当前工作目录："`pwd`
		git checkout -b $1.temp4shell remotes/origin/$1
			for i in $LIST
			do   
				echo "!!!!尝试删除本地分支："$i
				git checkout -b $1.temp4shell
				git pull
				git branch -D $i
				echo "!!!!忽略上边报错"
				git checkout -b $i remotes/origin/$i
				echo "!!!!重新检出分支："$i
				git branch -D $i
				git push origin --Delete $i
				echo "!!!! "$i" 分支删除完毕"
				git checkout -b $1 remotes/origin/$1
				git pull
				git checkout -b $i
				git push -u origin $i
				echo "!!!! "$i" 分支已从 "$1" 分支检出" 
			done
		git branch -D $1.temp4shell
		git push origin --Delete $1.temp4shell
		echo "-------- api end --------"
		echo "理论上 "$4" 项目的 "$LIST" 已重置完成，请到 gitlab 验收结果!!!"
		echo ""
		echo "Bye~"; break;;
       错误,退出程序 ) echo "Bye~";exit;;
   esac
done
~~~

