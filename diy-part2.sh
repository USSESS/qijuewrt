#!/bin/bash
set -e
# ========== 拉取iStoreOS软件源，编译内置iStore商店 ==========
git clone https://github.com/istoreos/istoreos-feed package/istoreos-feed
echo "src-git istoreos https://github.com/istoreos/istoreos-feed.git" >> feeds.conf.default
./scripts/feeds update istoreos
./scripts/feeds install -a -p istoreos

# 强制安装中文包、mwan3负载均衡进固件
./scripts/feeds install luci-i18n-base-zh-cn
./scripts/feeds install luci-i18n-argon-config-zh-cn
./scripts/feeds install mwan3-nft

# ==========系统全局名称 KiJueWrt ==========
# 修改openwrt_release 系统信息（源码层）
sed -i 's|ImmortalWrt|KiJueWrt|g' package/base-files/files/etc/openwrt_release
sed -i 's|OpenWrt|KiJueWrt|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_RELEASE=.*|DISTRIB_RELEASE='"'"'25.0.0.1'"'"'|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_CODENAME=.*|DISTRIB_CODENAME='"'"'KiJue'"'"'|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_DESCRIPTION=.*|DISTRIB_DESCRIPTION='"'"'KiJueWrt Built by GitHub Actions'"'"'|g' package/base-files/files/etc/openwrt_release

# 修改默认LAN IP为10.10.10.1
sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate
# 设置默认主机名 hostname = KiJueWrt
sed -i 's/set system.@system\[-1\].hostname=.*/set system.@system[0].hostname='\''KiJueWrt'\''/g' package/base-files/files/bin/config_generate

# ==========新建自定义uci-default脚本，开机自动执行==========
cat > package/base-files/files/etc/uci-defaults/99-kijuewrt <<"UCIEOF"
uci set luci.main.lang='zh-cn'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci set luci.main.mediaurlbase='/luci-static/edge'
uci commit luci
uci commit system
UCIEOF

# ==========SSH登录Banner KiJueWrt点阵（写入源码包）==========
cat > package/base-files/files/etc/banner <<"BANNEREOF"
░██     ░██ ░██    ░█████                       ░██       ░██             ░██
░██    ░██           ░██                        ░██       ░██             ░██
░██   ░██   ░██      ░██  ░██    ░██  ░███████  ░██  ░██  ░██ ░██░████ ░████████
░███████    ░██      ░██  ░██    ░██ ░██    ░██ ░██ ░████ ░██ ░███        ░██
░██   ░██   ░██░██   ░██  ░██    ░██ ░█████████ ░██░██ ░██░██ ░██         ░██
░██    ░██  ░██░██   ░██  ░██   ░███ ░██        ░████   ░████ ░██         ░██
░██     ░██ ░██ ░██████    ░█████░██  ░███████  ░███     ░███ ░██          ░████
=========================================================
             KiJueWrt 25.0.0.1
=========================================================
BANNEREOF

echo "diy‑part2 KiJueWrt全部设置完成"
