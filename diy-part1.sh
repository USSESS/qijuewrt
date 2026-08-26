#!/bin/bash

# 添加第三方软件源（fanchmwrt 多包合集）
echo "src-git fanchm https://github.com/fanchmwrt/fanchmwrt-packages.git" >> feeds.conf.default

# 添加 iStore 官方源和依赖源
echo "src-git istore https://github.com/linkease/istore;main" >> feeds.conf.default
echo "src-git nas https://github.com/linkease/nas-packages.git;master" >> feeds.conf.default
echo "src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main" >> feeds.conf.default

# 克隆 luci-theme-edge 主题源码（需要使用 master 分支）
git clone -b master https://github.com/r1172464137/luci-theme-edge.git package/luci-theme-edge

# 下载背景图并放到 edge 主题的默认背景目录（目录可能需随主题版本微调，通常是 htdocs/luci-static/edge/background/）
curl -L -o package/luci-theme-edge/htdocs/luci-static/edge/background/background.jpg "你的图片链接"
