#!/bin/bash
set -e
# ============================================================
#  KiJueWrt 云编译 diy-part2.sh（Argon 主题版）
#  修复点：feeds 顺序（已在 diy-part1.sh 修复），默认主题指向 argon
# ============================================================
# ==========系统全局名称 KiJueWrt ==========
sed -i 's|ImmortalWrt|KiJueWrt|g' package/base-files/files/etc/openwrt_release
sed -i 's|OpenWrt|KiJueWrt|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_RELEASE=.*|DISTRIB_RELEASE='"'"'24.10.6'"'"'|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_CODENAME=.*|DISTRIB_CODENAME='"'"'KiJue'"'"'|g' package/base-files/files/etc/openwrt_release
sed -i 's|DISTRIB_DESCRIPTION=.*|DISTRIB_DESCRIPTION='"'"'KiJueWrt Built by GitHub Actions'"'"'|g' package/base-files/files/etc/openwrt_release
# 修改默认LAN IP 10.10.10.1
sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate
# 修改主机名
sed -i 's/set system.@system\[-1\].hostname=.*/set system.@system[0].hostname='\''KiJueWrt'\''/g' package/base-files/files/bin/config_generate
# 写入uci-defaults：时区上海、中文、默认 argon 主题、/opt自动挂载、Docker数据目录
cat > package/base-files/files/etc/uci-defaults/99-custom <<EOF
uci set system.@system[0].timezone='Asia/Shanghai'
uci set system.@system[0].lang='zh_cn'
uci set luci.main.mediaurlbase='/luci-static/argon'
# /dev/sda3 自动挂载到 /opt（fstab方式，开机即挂载，比rc.local更可靠）
uci add fstab mount
uci set fstab.@mount[-1].target='/opt'
uci set fstab.@mount[-1].device='/dev/sda3'
uci set fstab.@mount[-1].fstype='ext4'
uci set fstab.@mount[-1].options='rw,noatime'
uci set fstab.@mount[-1].enabled='1'
# Docker 数据目录指向 /opt/docker（不占系统分区）
mkdir -p /opt/docker
cat > /etc/config/dockerd <<DOCKEREOF
config dockerd docker
	option data_root '/opt/docker'
DOCKEREOF
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
             KiJueWrt 24.10.6
=========================================================
BANNEREOF
echo "✅ diy-part2 KiJueWrt全部设置完成"
