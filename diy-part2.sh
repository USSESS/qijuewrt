#!/bin/bash
set -e
# ========== 系统全局名称 KiJueWrt ==========
sed -i 's|ImmortalWrt|KiJueWrt|g' package/base-files/files/etc/openwrt_release
sed -i 's|OpenWrt|KiJueWrt|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_RELEASE=.*|DISTRIB_RELEASE='"'"'25.0.0.1'"'"'|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_CODENAME=.*|DISTRIB_CODENAME='"'"'KiJue'"'"'|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_DESCRIPTION=.*|DISTRIB_DESCRIPTION='"'"'KiJueWrt Built by GitHub Actions'"'"'|g' package/base-files/files/etc/openwrt_release
# 修改默认 LAN IP 为 10.10.10.1
sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate
# 设置默认主机名 KiJueWrt
sed -i 's/set system.@system\[-1\].hostname=.*/set system.@system[0].hostname='\''KiJueWrt'\''/g' package/base-files/files/bin/config_generate

# ========== 【中文修复】files 目录预写 LuCI 配置，双块结构 ==========
# 关键：新版 LuCI 语言设置走 luci.main.lang（config main 块），必须同时写 core 和 main。
# 默认主题用 kijue（主题自带的 99-luci-theme-kijue 会进一步设置首页和主题参数）
mkdir -p files/etc/config
cat > files/etc/config/luci <<'LUCIEOF'
config core
	option lang 'auto'
	option mediaurlbase '/luci-static/kijue'

config main
	option lang 'zh_cn'
LUCIEOF

# ========== uci-defaults 开机脚本：默认中文 + 时区 + kijue 主题 ==========
# 注意：kijue 主题自带的 99-luci-theme-kijue 会在本脚本之后执行，
# 会进一步设置 mediaurlbase 和首页为 kijue 仪表盘，这里保持一致即可。
cat > package/base-files/files/etc/uci-defaults/99-kijuewrt <<"UCIEOF"
uci set luci.main.lang='zh_cn'
uci set luci.main.mediaurlbase='/luci-static/kijue'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit luci
uci commit system
exit 0
UCIEOF

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
echo "diy-part2 KiJueWrt 全部设置完成"
