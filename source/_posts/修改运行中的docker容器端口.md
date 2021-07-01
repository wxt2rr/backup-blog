---
title: 修改已经运行的docker容器的端口
date: 2021-06-29 22:25:00
summary: 修改docker容器端口映射
categories: Docker
tags:
  - docker容器
---

> 一开始博客没有加Nginx，我把docker容器直接映射到了宿主机的80端口，后来加入了Nginx来管理静态资源、ssl等，这时候80端口被占用了，所以需要修改正在运行的docker容器映射的宿主机的端口。

#### 一、删除原有容器，重新启动一个容器

把原来的容器删掉，重新启动一个，完了启动修改 端口映射 -p 为新的端口。

* 这里我就不演示了，因为我没用这个方法，懒得重新配置一遍....

#### 二、修改原有容器配置文件中的端口映射

```sh
# 获取正在运行的dokcer容器
[root@iZ8vb7tm9o88h6ioml28vsZ ~]# docker ps
CONTAINER ID   IMAGE        COMMAND                  CREATED       STATUS        PORTS                                       NAMES
77e6bfccd1cd   hexo-image   "docker-entrypoint.s…"   10 days ago   Up 36 hours   0.0.0.0:4000->4000/tcp, :::4000->4000/tcp   hexo-blog
# 我们先停掉正在运行的docker容器
[root@iZ8vb7tm9o88h6ioml28vsZ containers]# docker stop hexo-blog
# 然后进入docker容器配置的容器列表路径，这里显示了我们运行过的容器的HASH值
[root@iZ8vb7tm9o88h6ioml28vsZ ~]# cd /var/lib/docker/containers/
[root@iZ8vb7tm9o88h6ioml28vsZ containers]# ll
total 16
drwx-----x 4 root root 4096 Jun 29 22:24 0689cb3baaf4adfc9f1b7a30327080a584faebdb6af3a29ad02a9f987f419869
drwx-----x 4 root root 4096 Jun 29 22:24 1d0449bb8923092474efbdc6c9b65097898131105e7d5ea12809883a752fa407
drwx-----x 4 root root 4096 Jun 29 22:24 77e6bfccd1cd7cb85dc9548e507caf99052b80c95889304d6219ba54b894b896
drwx-----x 4 root root 4096 Jun 29 22:24 cf57f70841c097654c76787478a0648722ac8c9a0d9f88738495c36de4fc2ea5
# 这时我们进入以上边查询到容器的CONTAINER ID开头的文件夹，并打开 hostconfig.json 配置文件
[root@iZ8vb7tm9o88h6ioml28vsZ containers]# vim 77e6bfccd1cd7cb85dc9548e507caf99052b80c95889304d6219ba54b894b896/hostconfig.json
```

```json
{
    "Binds":[
        "/usr/hexo-blog/my-blog/:/usr/blog/my-blog/",
        "/usr/hexo-blog/:/usr/blog"
    ],
    "ContainerIDFile":"",
    "LogConfig":{
        "Type":"json-file",
        "Config":{

        }
    },
    "NetworkMode":"default",
    "PortBindings":{
        "80/tcp":[
            {
                "HostIp":"",
                "HostPort":"80"
            }
        ]
    },
    "RestartPolicy":{
        "Name":"no",
        "MaximumRetryCount":0
    },
    "AutoRemove":false,
    "VolumeDriver":"",
    "VolumesFrom":null,
    "CapAdd":null,
    "CapDrop":null,
    "CgroupnsMode":"host",
    "Dns":[

    ],
    "DnsOptions":[

    ],
    "DnsSearch":[

    ],
    "ExtraHosts":null,
    "GroupAdd":null,
    "IpcMode":"private",
    "Cgroup":"",
    "Links":null,
    "OomScoreAdj":0,
    "PidMode":"",
    "Privileged":false,
    "PublishAllPorts":false,
    "ReadonlyRootfs":false,
    "SecurityOpt":null,
    "UTSMode":"",
    "UsernsMode":"",
    "ShmSize":67108864,
    "Runtime":"runc",
    "ConsoleSize":[
        0,
        0
    ],
    "Isolation":"",
    "CpuShares":0,
    "Memory":0,
    "NanoCpus":0,
    "CgroupParent":"",
    "BlkioWeight":0,
    "BlkioWeightDevice":[

    ],
    "BlkioDeviceReadBps":null,
    "BlkioDeviceWriteBps":null,
    "BlkioDeviceReadIOps":null,
    "BlkioDeviceWriteIOps":null,
    "CpuPeriod":0,
    "CpuQuota":0,
    "CpuRealtimePeriod":0,
    "CpuRealtimeRuntime":0,
    "CpusetCpus":"",
    "CpusetMems":"",
    "Devices":[

    ],
    "DeviceCgroupRules":null,
    "DeviceRequests":null,
    "KernelMemory":0,
    "KernelMemoryTCP":0,
    "MemoryReservation":0,
    "MemorySwap":0,
    "MemorySwappiness":null,
    "OomKillDisable":false,
    "PidsLimit":null,
    "Ulimits":null,
    "CpuCount":0,
    "CpuPercent":0,
    "IOMaximumIOps":0,
    "IOMaximumBandwidth":0,
    "MaskedPaths":[
        "/proc/asound",
        "/proc/acpi",
        "/proc/kcore",
        "/proc/keys",
        "/proc/latency_stats",
        "/proc/timer_list",
        "/proc/timer_stats",
        "/proc/sched_debug",
        "/proc/scsi",
        "/sys/firmware"
    ],
    "ReadonlyPaths":[
        "/proc/bus",
        "/proc/fs",
        "/proc/irq",
        "/proc/sys",
        "/proc/sysrq-trigger"
    ]
}
```

打开之后是个json，我们格式化，然后找到 **PortBindings** 这个key，以我的配置为例，其中4000/tcp对应的是docker容器内部的端口，HostPort对应的是映射到宿主机的端口。这时候我们修改宿主机的端口为自己想修改的端口，然后重启docker服务，再启动容器服务就可以了。

```sh
# 重启docker服务
[root@iZ8vb7tm9o88h6ioml28vsZ containers]# systemctl restart docker
# 启动dokcer容器
[root@iZ8vb7tm9o88h6ioml28vsZ containers]# docker start hexo-blog
```

#### 三、将已有的docker容器再打包成一个镜像

把已经配置好或者正在运行的容器，在打包成一个新的镜像，之后通个这个新镜像，重新启动一个80端口的容器，原有容器可以删除或者停掉。

```sh
# 获取正在运行的dokcer容器
[root@iZ8vb7tm9o88h6ioml28vsZ ~]# docker ps
CONTAINER ID   IMAGE        COMMAND                  CREATED       STATUS        PORTS                                       NAMES
77e6bfccd1cd   hexo-image   "docker-entrypoint.s…"   10 days ago   Up 36 hours   0.0.0.0:4000->4000/tcp, :::4000->4000/tcp   hexo-blog
# 我们先停掉正在运行的docker容器
[root@iZ8vb7tm9o88h6ioml28vsZ containers]# docker stop hexo-blog
# 将容器打包成镜像提交，命令是 docker commit 容器名字 新镜像名字:标签
[root@iZ8vb7tm9o88h6ioml28vsZ containers]# docker commit hexo-blog wxt-hexo-blog:1.0
sha256:79f63a5a9f30632ed1617083166b0504f633b47d84e36694be51029883a146d4
# 这时候我们看已经有我们新的镜像了
[root@iZ8vb7tm9o88h6ioml28vsZ containers]# docker images
REPOSITORY      TAG       IMAGE ID       CREATED         SIZE
wxt-hexo-blog   1.0       79f63a5a9f30   8 seconds ago   950MB
# 我们启动一下，映射新的80端口
docker run --name new-hexo-blog -p 80:80 wxt-hexo-blog:1.0
```

#### 四、总结

* 第一种：方式简单，干净利落，但是如果我们之前的容器中配置很多东西，需要从头重新配置一次，就很繁琐，如果容器很轻，没有什么东西，或者我们可以很迅速的配置一个新的容器，那第一种还是相对方便的；
* 第二种：不需要重新配置容器，操作也还是算简单，但是会短暂的停止整个dokcer服务，如果服务器内还有其他容器正在运行则也会受到影响；如果服务器内其它容器受到的影响可以忽略，那第二种是适合的；
* 第三种：相对前两种方法，不需要重新配置容器，也不会对其它容器造成影响，但是会多很多无用（我自认为是无用）的镜像，这个也是看自己关注不关注那些镜像吧。
