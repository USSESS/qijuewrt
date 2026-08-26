#!/bin/bash

# 添加第三方软件源，存在则跳过，避免重复
grep -q "^src-git fanchm" feeds.conf.default || echo "src-git fanchm https://github.com/fanchmwrt/fanchmwrt-packages.git" >> feeds.conf.default
grep -q "^src-git istore" feeds.conf.default || echo "src-git istore https://github.com/linkease/istore;main" >> feeds.conf.default
grep -q "^src-git nas " feeds.conf.default || echo "src-git nas https://github.com/linkease/nas-packages.git;master" >> feeds.conf.default
grep -q "^src-git nas_luci" feeds.conf.default || echo "src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main" >> feeds.conf.default

# 克隆自定义 edge 主题，已存在就删除重新拉取，避免旧缓存
[ -d "package/luci-theme-edge" ] && rm -rf package/luci-theme-edge
git clone -b master https://github.com/USSESS/luci-theme-edge.git package/luci-theme-edge
