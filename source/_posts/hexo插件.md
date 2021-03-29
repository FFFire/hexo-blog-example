---
title: hexo插件
tags:
  - hexo
abbrlink: 5a3fb175
date: 2021-03-29 12:11:11
---
# 1. 前言
由于<<hexo的搭建和部署>>一文已经比较长了，就不想再将之后找到的插件部分内容添加到其中，于是另开一文来记录。本文主要记录在搭建好hexo博客后，一些值得安装的插件。
<!-- more -->
# 2. [Hexo-abbrlink](https://github.com/Rozbo/hexo-abbrlink)
原本hexo生成文章的链接包含了文章名称，例如显示为
```
lissettecarlr.com/2021/03/15/hexo的搭建和部署/
```
在复制后就会被翻译为：
```
https://lissettecarlr.com/2021/03/15/hexo%E7%9A%84%E6%90%AD%E5%BB%BA%E5%92%8C%E9%83%A8%E7%BD%B2/
```
就很长一条，使用次插件可以生成一个自增的id的静态链接。

## 2.1 安装
```
npm install hexo-abbrlink --save
```
修改\_config.yml文件，搜索permalink找到
```
permalink: :year/:month/:day/:title/
```
改为
```
permalink: posts/:abbrlink/
abbrlink:
    alg: crc32   #support crc16(default) and crc32
    rep: hex     #生成链接使用16进制表示： support dec(default) and hex
```
## 2.2 结果
链接变成了如下
```
http://localhost:4000/posts/5a3fb175/
```
如果发现是undefined，那就先hexo clean下。