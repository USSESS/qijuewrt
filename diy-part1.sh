#!/bin/bash

# 添加第三方软件源（fanchmwrt 多包合集）
echo "src-git fanchm https://github.com/fanchmwrt/fanchmwrt-packages.git" >> feeds.conf.default

# 添加 iStore 官方源和依赖源
echo "src-git istore https://github.com/linkease/istore;main" >> feeds.conf.default
echo "src-git nas https://github.com/linkease/nas-packages.git;master" >> feeds.conf.default
echo "src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main" >> feeds.conf.default

# 克隆你自己分叉的 luci-theme-edge 主题（图片已包含在这个仓库里）
git clone -b master https://github.com/USSESS/luci-theme-edge.git package/luci-theme-edge
