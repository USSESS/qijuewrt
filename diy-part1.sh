#!/bin/bash
set -e
# 添加feeds源
echo "src-git netwizard https://github.com/sirpdboy/luci-app-netwizard.git;main" >> feeds.conf.default
echo "src-git istore https://github.com/linkease/istore.git;main" >> feeds.conf.default

# 复制edge主题
if [ -d "$GITHUB_WORKSPACE/luci-theme-edge-master" ];then
    cp -r "$GITHUB_WORKSPACE/luci-theme-edge-master" package/luci-theme-edge
    echo "OK:Edge主题复制完成"
else
    echo "ERROR:缺失edge主题文件夹"
    exit 1
fi

# KiJueWrt主题
mv luci-theme-kijue package/
echo "OK:KiJueWrt主题移动完成"

# 更新安装feeds
./scripts/feeds update -a
./scripts/feeds install -a

echo "diy-part1.sh执行完毕"
