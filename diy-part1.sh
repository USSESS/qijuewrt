#!/bin/bash
set -e

# iStore软件中心源
echo "src-git istore https://github.com/linkease/istore.git;main" >> feeds.conf.default
# 拉取你的定制edge主题，【重要：分支改为master！！】
echo "src-git edge_theme https://github.com/USSESS/luci-theme-edge.git;master" >> feeds.conf.default

echo "diy‑part1 完成"
