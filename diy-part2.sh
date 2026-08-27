#!/bin/bash
set -e
# ==========系统全局名称 KiJueWrt ==========
# 修改openwrt_release 系统信息
sed -i 's|ImmortalWrt|KiJueWrt|g' package/base-files/files/etc/openwrt_release
sed -i 's|OpenWrt|KiJueWrt|g' package/base-files/files/etc/openwrt_release

# 修改默认LAN IP为10.10.10.1
sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate

# 设置默认主机名 hostname = KiJueWrt
sed -i "s/set system.@system\[-1\].hostname=.*/set system.@system[-1].hostname='KiJueWrt'/g" package/base-files/files/bin/config_generate

# ==========新建自定义uci-default脚本（替代原来修改99-default-settings）==========
cat > package/base-files/files/etc/uci-defaults/99-kijuewrt <<"UCIEOF"
uci set luci.main.lang='zh_cn'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci set luci_themes.@theme[0].rtheme='edge'
uci commit luci
uci commit system
UCIEOF

# 修改LuCI登录页面标题为 KiJueWrt，容错防止文件不存在编译中断
sed -i 's|ImmortalWrt|KiJueWrt|g' feeds/edge_theme/luci-theme-edge/luci-theme-edge.lua 2>/dev/null || true
sed -i 's|OpenWrt|KiJueWrt|g' feeds/edge_theme/luci-theme-edge/luci-theme-edge.lua 2>/dev/null || true

# ========== SSH登录Banner KiJueWrt点阵 ==========
cat > package/base-files/files/etc/banner <<"EOF"
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
EOF

echo "diy‑part2 KiJueWrt全部设置完成"
