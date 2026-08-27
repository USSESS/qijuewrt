#!/bin/bash
set -e

# iStore软件中心源
echo "src-git istore https://github.com/linkease/istore.git;main" >> feeds.conf.default

# 【已全部删除远程拉取edge主题代码，完全使用本仓库本地修改好的主题，不会被网上源码覆盖】
# 把仓库内package下整套edge主题复制到编译环境
cp -r $GITHUB_WORKSPACE/package/luci-theme-edge-master package/luci-theme-edge

# 更新feeds
./scripts/feeds update -a
./scripts/feeds install -a

echo "diy‑part1.sh执行完毕：本地定制edge主题已导入"
