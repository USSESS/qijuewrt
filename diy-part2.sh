#!/bin/bash

# 1. 将系统内所有的 ImmortalWrt 字样替换为 KiJueWrt
sed -i 's/ImmortalWrt/KiJueWrt/g' package/base-files/files/etc/openwrt_release
sed -i 's/ImmortalWrt/KiJueWrt/g' package/base-files/files/etc/banner
grep -r "ImmortalWrt" feeds/luci -l 2>/dev/null | xargs sed -i 's/ImmortalWrt/KiJueWrt/g' 2>/dev/null

# 2. 修改默认 IP (取消注释生效，默认改为 192.168.50.5)
#sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate

# 3. 修改默认主题 (可选)
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 4. 修改 Hostname (取消注释生效)
# sed -i 's/OpenWrt/KiJueWrt/g' package/base-files/files/bin/config_generate

# 5. 设置 x86-64 架构
echo 'CONFIG_TARGET_x86_64=y' >> .config
echo 'CONFIG_TARGET_x86_64_Generic=y' >> .config

# 6. 启用负载均衡插件 mwan3
echo 'CONFIG_PACKAGE_luci-app-mwan3=y' >> .config
echo 'CONFIG_PACKAGE_mwan3=y' >> .config

# 7. 启用 fwx 相关插件
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
