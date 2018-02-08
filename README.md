# 这是什么地方

------

理解需要更便捷更高效的工具或者有时需要记录思想，整理笔记、知识，并将其中承载的价值传播给他人，**Joey** 是我个人分享的地方 —— 为记录思想和分享知识提供更专业的工具。

> * 整理知识，学习笔记
> * 发布日记，杂文，所见所想
> * 撰写发布技术文稿（代码支持）
> * 撰写发布学术论文（LaTeX 公式支持）
> * 备份文档
> * 个人小脚本



### [SS/SSR Python备份文档](https://github.com/JoeJoeyMa/joey)

> 内置文件包含一些脚本(other)和个人分享，图床(img)

------

## 什么是 qrencode

qrencode 是一种方便展示把ss/ssr链接在shell终端生成二维码的工具。当然你用它生成任何形式的二维码（无论是个人链接或者是支付二维码）

### 1. 如何安装 [qrencode](https://github.com/fukuchi/libqrencode)

- [ ] Fedora: sudo dnf install qrencode
- [ ] Centos: yum install qrencode
- [ ] Debian: Almost same Centos
- [x] 支持在shell终端生成二维码并展示
- [x] 可以生成几乎所有形式的二维码
- [x] 可集成于其他项目中一起使用

### 2. other文件内的个人脚本

$$https://github.com/JoeJoeyMa/joey/tree/master/other$$

###  img个人图床









###  绘制表格

| 项目        | 项目地址   |  简介  |
| --------   | -----:  | :----:  |
| Blog     | https://github.com/JoeJoeyMa/Django2.0-Blog |   个人基于Django搭建blog   |
| Joey        |   https://github.com/JoeJoeyMa/joey   |   个人文档   |
| other        |    other   |  other  |





ShadowsocksR
===========

[![Build Status]][Travis CI]

A fast tunnel proxy that helps you bypass firewalls.

Server
------

### Install

Debian / Ubuntu:

    apt-get install git
    git clone https://github.com/shadowsocksr/shadowsocksr.git

CentOS:

    yum install git
    git clone https://github.com/shadowsocksr/shadowsocksr.git

Windows:

    git clone https://github.com/shadowsocksr/shadowsocksr.git

### Usage for single user on linux platform

If you clone it into "~/shadowsocksr"  
move to "~/shadowsocksr", then run:

    bash initcfg.sh

move to "~/shadowsocksr/shadowsocks", then run:

    python server.py -p 443 -k password -m aes-128-cfb -O auth_aes128_md5 -o tls1.2_ticket_auth_compatible

Check all the options via `-h`.

You can also use a configuration file instead (recommend), move to "~/shadowsocksr" and edit the file "user-config.json", then move to "~/shadowsocksr/shadowsocks" again, just run:

    python server.py

To run in the background:

    ./logrun.sh

To stop:

    ./stop.sh

To monitor the log:

    ./tail.sh


Client
------

* [Windows] / [macOS]
* [Android] / [iOS]
* [OpenWRT]

Use GUI clients on your local PC/phones. Check the README of your client
for more information.

Documentation
-------------

You can find all the documentation in the [Wiki].

License
-------

Copyright 2015 clowwindy

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations
under the License.

Bugs and Issues
----------------

* [Issue Tracker]



[Android]:           https://github.com/shadowsocksr/shadowsocksr-android
[Build Status]:      https://travis-ci.org/shadowsocksr/shadowsocksr.svg?branch=manyuser
[Debian sid]:        https://packages.debian.org/unstable/python/shadowsocks
[iOS]:               https://github.com/shadowsocks/shadowsocks-iOS/wiki/Help
[Issue Tracker]:     https://github.com/shadowsocksr/shadowsocksr/issues?state=open
[OpenWRT]:           https://github.com/shadowsocks/openwrt-shadowsocks
[macOS]:             https://github.com/shadowsocksr/ShadowsocksX-NG
[Travis CI]:         https://travis-ci.org/shadowsocksr/shadowsocksr
[Windows]:           https://github.com/shadowsocksr/shadowsocksr-csharp
[Wiki]:              https://github.com/breakwa11/shadowsocks-rss/wiki

Fedora: 
sudo dnf install qrencode 

Centos: 
yum install qrencode 
