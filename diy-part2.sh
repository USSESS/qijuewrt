#!/bin/bash
#
# diy-part2.sh — KiJueWrt 自定义edge主题版本
# feeds install完成后执行，只修改源码文件，不修改.config
#

# ========== 系统名称替换 KiJueWrt ==========
sed -i 's/ImmortalWrt/KiJueWrt/g' package/base-files/files/etc/openwrt_release
sed -i 's/OpenWrt/KiJueWrt/g' package/base-files/files/bin/config_generate
grep -r "ImmortalWrt" feeds/luci package/*/luci* -l 2>/dev/null | xargs sed -i 's/ImmortalWrt/KiJueWrt/g' 2>/dev/null

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

# ========== 设置 edge 为LuCI默认主题 ==========
sed -i 's/luci-theme-bootstrap/luci-theme-edge/g' feeds/luci/modules/luci-base/root/etc/config/luci
