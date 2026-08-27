#!/bin/bash
set -e

# iStore软件中心源
echo "src-git istore https://github.com/linkease/istore.git;main" >> feeds.conf.default
# 拉取你的定制 edge主题
echo "src-git edge_theme https://github.com/USSESS/luci-theme-edge.git;main" >> feeds.conf.default

echo "diy‑part1 完成"
