#!/bin/bash
set -e
# ==========系统全局名称 KiJueWrt ==========
sed -i 's|ImmortalWrt|KiJueWrt|g' package/base-files/files/etc/openwrt_release
sed -i 's|OpenWrt|KiJueWrt|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_RELEASE=.*|DISTRIB_RELEASE='"'"'25.0.0.1'"'"'|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_CODENAME=.*|DISTRIB_CODENAME='"'"'KiJue'"'"'|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_DESCRIPTION=.*|DISTRIB_DESCRIPTION='"'"'KiJueWrt Built by GitHub Actions'"'"'|g' package/base-files/files/etc/openwrt_release
# 修改默认LAN IP为10.10.10.1
sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate
# 设置默认主机名 KiJueWrt
sed -i 's/set system.@system\[-1\].hostname=.*/set system.@system[0].hostname='\''KiJueWrt'\''/g' package/base-files/files/bin/config_generate

# ========== 【追加修复1】files目录预写配置，双保险固化默认中文 ==========
# 原来的uci-defaults脚本保留，这里额外直接写配置文件进固件，确保100%生效
mkdir -p files/etc/config
cat > files/etc/config/luci <<'LUCIEOF'
config core
	option lang 'zh_cn'
	option mediaurlbase '/luci-static/edge'
LUCIEOF

# ========== 【追加修复2】netwizard页面强制汉化，绕过翻译包失效bug ==========
NW_FILE="usr/lib/lua/luci/view/netwizard/index.htm"
if [ -f "$NW_FILE" ]; then
    sed -i 's/Select Network Connection Mode/选择网络连接模式/g' "$NW_FILE"
    sed -i 's/Choose the connection mode that matches your network environment/请选择匹配你环境的上网方式/g' "$NW_FILE"
    sed -i 's/PPPoE Dial-up/PPPoE拨号/g' "$NW_FILE"
    sed -i 's/DHCP Client/DHCP自动获取/g' "$NW_FILE"
    sed -i 's/Side Router/旁路由模式/g' "$NW_FILE"
    sed -i 's/Static IP/静态IP/g' "$NW_FILE"
    sed -i 's/Next/下一步/g' "$NW_FILE"
    sed -i 's/Back/上一步/g' "$NW_FILE"
    sed -i 's/Finish/完成/g' "$NW_FILE"
    echo "netwizard页面已强制汉化"
else
    echo "警告：netwizard模板文件不存在，跳过硬汉化"
fi

# ========== uci‑defaults 开机脚本：默认中文+时区【已修正 zh_cn 下划线】 ==========
# 【你原来的代码，完全保留不动】
cat > package/base-files/files/etc/uci-defaults/99-kijuewrt <<"UCIEOF"
uci set luci.main.lang='zh_cn'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci set luci.main.mediaurlbase='/luci-static/edge'
uci commit luci
uci commit system
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
echo "diy‑part2 KiJueWrt全部设置完成"
