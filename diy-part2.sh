#!/bin/bash
set -e
# ==========系统全局名称 KiJueWrt ==========
# 修改openwrt_release 系统信息
sed -i 's|ImmortalWrt|KiJueWrt|g' package/base-files/files/etc/openwrt_release
sed -i 's|OpenWrt|KiJueWrt|g' package/base-files/files/etc/openwrt_release

# 设置默认中文、上海时区
sed -i "s/option lang='en'/option lang='zh_cn'/g" package/base-files/files/etc/uci-defaults/99-default-settings
sed -i "s/option timezone='UTC'/option timezone='Asia\/Shanghai'/g" package/base-files/files/etc/uci-defaults/99-default-settings

# 设置开机默认使用 edge主题（你的定制主题）
sed -i "/config theme/d" package/base-files/files/etc/uci-defaults/99-default-settings
echo -e "config theme\n\toption rtheme 'edge'" >> package/base-files/files/etc/uci-defaults/99-default-settings

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
