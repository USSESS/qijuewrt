#!/bin/bash

# 1. 系统名称替换（确保网页左上角和右上角彻底变成 KiJueWrt）
sed -i 's/ImmortalWrt/KiJueWrt/g' package/base-files/files/etc/openwrt_release
sed -i 's/OpenWrt/KiJueWrt/g' package/base-files/files/bin/config_generate
grep -r "ImmortalWrt" feeds/luci -l 2>/dev/null | xargs sed -i 's/ImmortalWrt/KiJueWrt/g' 2>/dev/null

# 2. 设置 x86-64 架构
echo 'CONFIG_TARGET_x86_64=y' >> .config
echo 'CONFIG_TARGET_x86_64_Generic=y' >> .config

# 3. 启用负载均衡插件 mwan3
echo 'CONFIG_PACKAGE_luci-app-mwan3=y' >> .config
echo 'CONFIG_PACKAGE_mwan3=y' >> .config

# 4. 启用 fwx 相关插件
echo 'CONFIG_PACKAGE_luci-app-fwx-dashboard=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-fwx-dashboard-setting=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-fwx-feature=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-fwx-macfilter=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-fwx-session-stat=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-fwx-record=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-fwx-record-whitelist=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-fwx-resources=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-fwx-system=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-fwx-user-record=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-fwx-app-center=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-fwx-network=y' >> .config

# 5. 启用 iStore 应用商店及必备组件
echo 'CONFIG_PACKAGE_luci-app-store=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-istorex=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-quickstart=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-linkease=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-ddnsto=y' >> .config

# 6. 添加 iStore 汉化包（本地化界面）
echo 'CONFIG_PACKAGE_luci-i18n-istorex-zh-cn=y' >> .config
echo 'CONFIG_PACKAGE_luci-i18n-quickstart-zh-cn=y' >> .config

# 7. 添加 iStore 必需的底层依赖
echo 'CONFIG_PACKAGE_luci-compat=y' >> .config
echo 'CONFIG_PACKAGE_luci-lib-taskd=y' >> .config
echo 'CONFIG_PACKAGE_luci-lib-xterm=y' >> .config

# 8. 启用基础系统中文语言包
echo 'CONFIG_PACKAGE_luci-i18n-base-zh-cn=y' >> .config
echo 'CONFIG_PACKAGE_luci-i18n-firewall-zh-cn=y' >> .config

# 9. 启用 luci-theme-edge 主题并设为默认（请确保下方没有 argon 等旧主题的代码）
echo 'CONFIG_PACKAGE_luci-theme-edge=y' >> .config
# 强制将默认主题改为 edge（默认是 bootstrap）
sed -i "s/bootstrap/edge/g" feeds/luci/modules/luci-base/root/etc/config/luci

# 10. 覆盖开机 LOGO（KiJueWrt 方块艺术字定制版）
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
