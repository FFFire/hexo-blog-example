---
title: docker与hexo
date: 2021-03-15 10:00:00
tags:
    - docker
    - hexo
---

# 1. 前言
主要是想将hexo弄到群晖NAS中去，但是又不想在原本系统中操作，发现里面有docker的应用，就顺便学习学习，捣鼓一下咯。几年前就在同学那里听说了docker，但是一直没机会接触。

<!-- more -->

# 2. 目的
* 学习docker
* 使用docker让hexo在群晖里面跑起来，达到在局域网内使用，定时更新。
-----------
这里插一句，其实群晖搭建网站有个更加简单的方式，就是直接用Web Station套件。然后定时拉去github仓库里面最新的部署文件。几分钟完美达到目的。。。。所以本文主要还是学习用用docker啦- -|，其实一开始不是这么想的，蠢哭了。
![](docker与hexo/p_1.png)

-----------


# 3. 实现
## 3.1 手动做一个hexo的镜像

* 拉一个nodejs

```
docker pull node
```

* 用此镜像运行一个容器

```
docker run -i -t hexo-node /bin/bash
```

* 安装相关的软件

```
    apt-get update
    apt-get install git -y
    npm install -g hexo-cli
```

* 新建目录用于存放工程

```
    mkdir HexoBlog
    cd HexoBlog
    mkdir blog
```

* 拉取最新博客数据

```
    git config --global user.name "lissettecarlr"
    git config --global user.email lissettecarlr@163.com
    git clone -b blog https://github.com/xxxxxxx
```

* 新建博客

```
    cd blog
    hexo init
    npm install --save hexo-deployer-git
```

* 更新数据

```
    rm -r source 
    rm -r themes 
    rm _config.yml 
    cp ../lissettecarlr.github.io/_config.yml ./_config.yml 
    cp -r ../lissettecarlr.github.io/source ./ 
    cp -r ../lissettecarlr.github.io/themes ./ 
```

* 包装成镜像

```
docker commit ID hexo-node
```

* 运行
```
    docker run --name blog -i -t -p 4000:4000  hexo-node /bin/bash -c "cd HexoBlog/blog;hexo s"
```
可以看到
```
INFO  Validating config
INFO  Start processing
INFO  Hexo is running at http://localhost:4000 . Press Ctrl+C to stop.
```
直接退出则容器关闭，再次开启可以输入
```
docker restart 容器ID
```
删除容器可以输入
```
docker rm 容器ID
```
关闭容器可输入
```
docker stop 容器ID
```

## 3.2 使用Dockerfile构建
* 首先拉取nodejs
```
docker pull node
```
* 然后使用Dockerfile构建
```
FROM node:latest

ENV HEXO_SERVER_PORT=4000
WORKDIR /HexoBlog
EXPOSE 4000

RUN \
    apt-get update && \
    # apt-get install git -y && \
    git config --global user.name "lissettecarlr" && \
    git config --global user.email lissettecarlr@163.com && \
    git clone -b blog https://github.com/lissettecarlr/lissettecarlr.github.io.git && \
    mkdir Blog && cd Blog && \
    npm install -g npm && \
    npm install -g hexo-cli && \
    hexo init && \
    npm install --save hexo-deployer-git

CMD \
    rm -r ./lissettecarlr.github.io && \
    git clone -b blog https://github.com/lissettecarlr/lissettecarlr.github.io.git && \
    cd Blog && \
    rm -r source && \
    rm -r themes && \
    rm _config.yml && \
    cp ../lissettecarlr.github.io/_config.yml ./_config.yml && \
    cp -r ../lissettecarlr.github.io/source ./ && \
    cp -r ../lissettecarlr.github.io/themes ./ && \
    echo "config over" && \
    hexo s

```

```
docker bulid -t hexo_img .
```

* 最后运行起来
```
 docker run -i -t --name "hexo-test" -p 4000:4000 hexo_img
```



# 4. 其他

## 4.1 Dockerfile

* FROM：基于什么来构建镜像

```
FROM ubuntu
```

* WORKDIR：bash进入后的初始目录

```
WORKDIR /home/test
```

* COPY：从宿主机上复制到镜像中

```
COPY src/ /home/test
```

* RUN：在构建的时候执行的命令

```
RUN echo lalalala
```

* CMD：运行起来后执行的命令，执行完毕则容器生命周期结束

```
CMD ls
```

* 运行Dockerfile

```
docker build -t 镜像名称 .
```

* 运行镜像使其成为容器

```
docker run 镜像名称
```

* EXPOSE 暴露端口
* VOLUME 指定映射文件
* ENV指定变量全时段有效
* ARG指定变量只在构建的时候生效

## 4.2 docker基本命令

* 拉去镜像,默认latest
```
docker pull ubunut
```

* 列出本地镜像
```
docker imgaes
```

* 使用镜像运行一个容器
```
docker run --name MyUbuntu 
```
常用的参数：-d: 后台运行容器；-i: 以交互模式运行容器；-p: 指定端口映射，格式为：主机(宿主)端口:容器端口；-t: 为容器重新分配一个伪输入终端；

* 查看容器
```
docker ps -a
```

* 容器的基本操作
```
docker start MyUbuntu
docker stop MyUbuntu
docker restart MyUbuntu
docker rm MyUbuntu
```

* 连接正在运行的容器
```
docker attach MyUbuntu
```