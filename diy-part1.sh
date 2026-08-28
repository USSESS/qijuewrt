#!/bin/bash
set -e
# iStore软件中心源 linkease官方 main分支
echo "src-git istore https://github.com/linkease/istore.git;main" >> feeds.conf.default
# 一键上网设置向导 netwizard 源
echo "src-git netwizard https://github.com/sirpdboy/luci-app-netwizard.git;main" >> feeds.conf.default
# 本地导入仓库内定制Edge主题
if [ -d "$GITHUB_WORKSPACE/package/luci-theme-edge-master" ];then
    cp -r $GITHUB_WORKSPACE/package/luci-theme-edge-master package/luci-theme-edge
else
    echo "警告：本地Edge主题文件夹缺失，跳过复制"
fi
# 更新全部feeds
./scripts/feeds update -a
./scripts/feeds install -a
#强制安装关键包，避免.config写y但是固件没打包进去
./scripts/feeds install luci-app-store
./scripts/feeds install luci-app-netwizard
./scripts/feeds install luci-i18n-netwizard-zh-cn
./scripts/feeds install curl wget ca-certificates unzip tar
echo "diy‑part1.sh执行完毕：iStore、上网向导源、本地Edge主题已加载"
