#!/bin/bash
set -e

# 添加feeds源：netwizard一键向导
echo "src-git netwizard https://github.com/sirpdboy/luci-app-netwizard.git;main" >> feeds.conf.default
# 添加iStore feeds源，不再git clone移动文件，直接feeds拉取，彻底规避mv路径错误
echo "src-git istore https://github.com/linkease/istore.git;main" >> feeds.conf.default

#复制你仓库本地edge主题
if [ -d "$GITHUB_WORKSPACE/luci-theme-edge-master" ];then
    cp -r "$GITHUB_WORKSPACE/luci-theme-edge-master" package/luci-theme-edge
    echo "OK:Edge主题复制完成"
else
    echo "ERROR:缺失edge主题文件夹 luci-theme-edge-master"
    exit 1
fi

# 更新安装feeds
./scripts/feeds update -a
./scripts/feeds install -a

echo "diy‑part1.sh执行完毕"
