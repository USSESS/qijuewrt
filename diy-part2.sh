#!/bin/bash
#
# diy-part2.sh — KiJueWrt 定制：系统改名 + 插件配置 + 默认主题 + 开机 banner
# 在 ImmortalWrt 源码根目录执行（feeds 已 install 之后）
#
# ========== 1. 系统名称替换（网页左上角/右上角 + 版本文件） ==========
sed -i 's/ImmortalWrt/KiJueWrt/g' package/base-files/files/etc/openwrt_release
sed -i 's/OpenWrt/KiJueWrt/g' package/base-files/files/bin/config_generate
grep -r "ImmortalWrt" feeds/luci package/*/luci* -l 2>/dev/null | xargs sed -i 's/ImmortalWrt/KiJueWrt/g' 2>/dev/null

# ========== 2. 设置 x86-64 架构 ==========
echo 'CONFIG_TARGET_x86_64=y' >> .config
echo 'CONFIG_TARGET_x86_64_Generic=y' >> .config

# ========== 3. 启用 mwan3 多 WAN 负载均衡 ==========
echo 'CONFIG_PACKAGE_luci-app-mwan3=y' >> .config
echo 'CONFIG_PACKAGE_mwan3=y' >> .config

# ========== ⚠️【已删除fwx全套】没有源码，不能开启，否则编译报错 ==========

# ========== 4. 启用 iStore 应用商店及必备组件 ==========
echo 'CONFIG_PACKAGE_luci-app-store=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-istorex=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-quickstart=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-linkease=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-ddnsto=y' >> .config

# ========== 5. iStore 汉化包 ==========
echo 'CONFIG_PACKAGE_luci-i18n-istorex-zh-cn=y' >> .config
echo 'CONFIG_PACKAGE_luci-i18n-quickstart-zh-cn=y' >> .config

# ========== 6. iStore 底层依赖 ==========
echo 'CONFIG_PACKAGE_luci-compat=y' >> .config
echo 'CONFIG_PACKAGE_luci-lib-taskd=y' >> .config
echo 'CONFIG_PACKAGE_luci-lib-xterm=y' >> .config

# ========== 7. 基础系统中文语言包 ==========
echo 'CONFIG_PACKAGE_luci-i18n-base-zh-cn=y' >> .config
echo 'CONFIG_PACKAGE_luci-i18n-firewall-zh-cn=y' >> .config

# ========== 8. 启用 edge主题 ==========
echo 'CONFIG_PACKAGE_luci-theme-edge=y' >> .config

# ========== 9. 覆盖开机 LOGO（KiJueWrt 方块艺术字） ==========
cat > package/base-files/files/etc/banner << "EOF"
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
