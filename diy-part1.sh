#!/bin/bash
set -e
# iStore软件中心源
echo "src-git istore https://github.com/linkease/istore.git;main" >> feeds.conf.default
# 拉取定制edge主题 master分支
echo "src-git edge_theme https://github.com/USSESS/luci-theme-edge.git;master" >> feeds.conf.default

# 更新feeds
./scripts/feeds update -a
./scripts/feeds install -a

echo "diy‑part1 完成"
