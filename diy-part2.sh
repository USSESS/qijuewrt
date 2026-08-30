#!/bin/bash
set -e
# ==========系统全局名称 KiJueWrt ==========
sed -i 's|ImmortalWrt|KiJueWrt|g' package/base-files/files/etc/openwrt_release
sed -i 's|OpenWrt|KiJueWrt|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_RELEASE=.*|DISTRIB_RELEASE='"'"'25.0.0.1'"'"'|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_CODENAME=.*|DISTRIB_CODENAME='"'"'KiJue'"'"'|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_DESCRIPTION=.*|DISTRIB_DESCRIPTION='"'"'KiJueWrt Built by GitHub Actions'"'"'|g' package/base-files/files/etc/openwrt_release
# 修改默认LAN IP 10.10.10.1
sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate
# 修改主机名
sed -i 's/set system.@system\[-1\].hostname=.*/set system.@system[0].hostname='\''KiJueWrt'\''/g' package/base-files/files/bin/config_generate
# 写入uci-defaults：时区上海、中文、默认edge主题
cat > package/base-files/files/etc/uci-defaults/99-custom <<EOF
uci set system.@system[0].timezone='Asia/Shanghai'
uci set system.@system[0].lang='zh_cn'
uci set luci.main.mediaurlbase='/luci-static/edge'
uci commit
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-custom
# ========== SSH Banner ==========
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
echo "✅ diy-part2 KiJueWrt全部设置完成"
