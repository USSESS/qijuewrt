#!/bin/bash
#
# diy-part1.sh — KiJueWrt 定制：添加第三方源 + 拉取 edge 主题
# 在 ImmortalWrt 源码根目录执行
#
# ========== 1. 添加第三方软件源（已存在则跳过，避免重复写入） ==========
grep -q "^src-git fanchm" feeds.conf.default || echo "src-git fanchm https://github.com/fanchmwrt/fanchmwrt-packages.git" >> feeds.conf.default
grep -q "^src-git istore" feeds.conf.default || echo "src-git istore https://github.com/linkease/istore;main" >> feeds.conf.default
grep -q "^src-git nas" feeds.conf.default || echo "src-git nas https://github.com/linkease/nas-packages.git;master" >> feeds.conf.default
grep -q "^src-git nas_luci" feeds.conf.default || echo "src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main" >> feeds.conf.default

# ========== 2. 拉取自定义 edge 主题（旧目录先删，避免 clone 失败） ==========
[ -d "package/luci-theme-edge" ] && rm -rf package/luci-theme-edge
git clone -b master https://github.com/USSESS/luci-theme-edge.git package/luci-theme-edge

# diy-part1.sh：添加iStore源 + 使用自己修改的luci-theme-edge
echo 'src-git istore https://github.com/linkease/istore-packages.git;main' >> feeds.conf.default

# 删除feeds中原有的edge，替换为你自己改好的仓库
sed -i '/luci-theme-edge/d' feeds.conf.default
echo "src-git luci-theme-edge https://github.com/USSESS/luci-theme-edge.git" >> feeds.conf.default
