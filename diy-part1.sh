#!/bin/bash
set -e
# ============================================================
#  KiJueWrt 云编译 diy-part1.sh（Argon 主题 + OpenAppFilter 版）
#  修复点：
#   1) feeds update 移到 feeds install 之前（原脚本顺序是反的，会中断）
#   2) 主题改为原装 Argon（jerrykuku/luci-theme-argon），git clone 进 package/
#   3) 新增 OpenAppFilter 应用过滤（destan19/OpenAppFilter），git clone 进 package/
# ============================================================
# ---------- 添加第三方 feeds 源 ----------
echo "src-git istore https://github.com/linkease/istore.git;main" >> feeds.conf.default
echo "src-git netwizard https://github.com/sirpdboy/luci-app-netwizard.git;main" >> feeds.conf.default
echo "src-git ddnsgo https://github.com/sirpdboy/luci-app-ddns-go.git;main" >> feeds.conf.default
# ---------- 先更新、再安装全部 feeds（顺序不能反） ----------
./scripts/feeds update -a
./scripts/feeds install -a
# ---------- 克隆原装 Argon 主题到本地 package ----------
rm -rf package/luci-theme-argon
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
echo "OK:原装 Argon 主题克隆完成"
# ---------- 清理官方 feeds 中可能冲突的旧版 appfilter（避免与 destan19 版包名冲突） ----------
rm -rf package/feeds/packages/net/open-app-filter
rm -rf package/feeds/luci/applications/luci-app-appfilter
echo "OK:已清理官方 feeds 中可能冲突的旧版 appfilter"
# ---------- 克隆 OpenAppFilter 到本地 package ----------
rm -rf package/OpenAppFilter
git clone --depth 1 https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
echo "OK:OpenAppFilter 克隆完成"
# ---------- 强制安装关键包（防漏打包） ----------
./scripts/feeds install luci-app-store luci-compat
./scripts/feeds install luci-app-netwizard luci-i18n-netwizard-zh-cn
./scripts/feeds install ddns-go luci-app-ddns-go luci-i18n-ddns-go-zh-cn
./scripts/feeds install luci-i18n-zh-cn luci-i18n-base-zh-cn
./scripts/feeds install mwan3 luci-app-mwan3 luci-i18n-mwan3-zh-cn
./scripts/feeds install opkg opkg-update opkg-conf curl wget ca-certificates unzip tar
# ---------- 最终验证 ----------
echo "====== 关键包验证 ======"
[ -f package/luci-theme-argon/Makefile ] && echo "OK:Argon 主题已就位" || { echo "FAIL:Argon 主题缺失"; exit 1; }
[ -f package/OpenAppFilter/luci-app-oaf/Makefile ] && echo "OK:OpenAppFilter 已就位" || { echo "FAIL:OpenAppFilter 缺失"; exit 1; }
ls package/feeds/istore/ 2>/dev/null | grep -qE "store|compat" && echo "OK:iStore 源已拉取" || echo "WARN:iStore 源未确认"
ls package/feeds/ddnsgo/ 2>/dev/null | grep -qE "ddns" && echo "OK:ddns-go 源已拉取" || echo "WARN:ddns-go 源未确认"
ls package/feeds/luci/ 2>/dev/null | grep -qE "i18n-zh-cn|i18n-base-zh-cn" && echo "OK:中文包已安装" || echo "WARN:中文包未确认"
echo "====== diy-part1.sh 执行完毕 ======"
