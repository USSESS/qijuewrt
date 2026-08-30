#!/bin/bash
set -e
# 添加feeds源
echo "src-git netwizard https://github.com/sirpdboy/luci-app-netwizard.git;main" >> feeds.conf.default
echo "src-git istore https://github.com/linkease/istore.git;main" >> feeds.conf.default

# KiJueWrt主题（用$GITHUB_WORKSPACE绝对路径）
mv "$GITHUB_WORKSPACE/luci-theme-kijue" package/
echo "OK:KiJueWrt主题移动完成"

# 更新安装feeds
./scripts/feeds update -a
./scripts/feeds install -a

echo "diy-part1.sh执行完毕"
