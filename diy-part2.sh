#!/bin/bash
#
# diy-part2.sh — KiJueWrt 定制：系统改名 + 插件配置 + 默认主题 + 开机 banner
# 在 ImmortalWrt 源码根目录执行（feeds 已 install 之后）
#

# ========== 0. 清空旧 .config，防止残留配置干扰 ==========
rm -f .config
touch .config

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

# ========== 4. 启用 fwx 全套行为管理插件 ==========
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

# ========== 5. 启用 iStore 应用商店及必备组件 ==========
echo 'CONFIG_PACKAGE_luci-app-store=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-istorex=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-quickstart=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-linkease=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-ddnsto=y' >> .config

# ========== 6. iStore 汉化包 ==========
echo 'CONFIG_PACKAGE_luci-i18n-istorex-zh-cn=y' >> .config
echo 'CONFIG_PACKAGE_luci-i18n-quickstart-zh-cn=y' >> .config

# ========== 7. iStore 底层依赖 ==========
echo 'CONFIG_PACKAGE_luci-compat=y' >> .config
echo 'CONFIG_PACKAGE_luci-lib-taskd=y' >> .config
echo 'CONFIG_PACKAGE_luci-lib-xterm=y' >> .config

# ========== 8. 基础系统中文语言包 ==========
echo 'CONFIG_PACKAGE_luci-i18n-base-zh-cn=y' >> .config
echo 'CONFIG_PACKAGE_luci-i18n-firewall-zh-cn=y' >> .config

# ========== 9. 启用 edge 主题并精准设为默认（不再全局 sed 替换） ==========
echo 'CONFIG_PACKAGE_luci-theme-edge=y' >> .config
sed -i '/option theme/c\        option theme "edge"' feeds/luci/modules/luci-base/root/etc/config/luci

# ========== 10. 覆盖开机 LOGO（KiJueWrt 方块艺术字） ==========
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

# ====================== GRUB开机背景配置 1024×768通用版 ======================
GRUB_CFG="${GITHUB_WORKSPACE}/openwrt/package/boot/grub2/files/grub/grub.cfg"

# 将背景图片复制到grub打包目录
cp "${GITHUB_WORKSPACE}/openwrt/files/grub-bg.png" "${GITHUB_WORKSPACE}/openwrt/package/boot/grub2/files/grub/"

# 设置图形输出终端，优先1024x768，硬件不支持自动降级
sed -i '/^set timeout/a\set gfxmode=1024x768,auto' "$GRUB_CFG"
sed -i '/^set timeout/a\terminal_output gfxterm' "$GRUB_CFG"

# 设置背景图与主题模式
sed -i '/^set timeout/a\set background_image="grub-bg.png"' "$GRUB_CFG"
sed -i '/^set timeout/a\set theme_mode="prefer-dark"' "$GRUB_CFG"

# 设置菜单文字颜色，防止和图片融合看不清字
sed -i '/^set timeout/a\set color_normal=white/black' "$GRUB_CFG"
sed -i '/^set timeout/a\set color_highlight=cyan/blue' "$GRUB_CFG"

# 修改GRUB菜单等待时间，默认5秒改为2秒
sed -i 's/set timeout=5/set timeout=2/' "$GRUB_CFG"
