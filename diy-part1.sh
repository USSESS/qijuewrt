、#!/bin/bash
set -e

# iStore软件中心源 linkease官方 main分支
echo "src-git istore https://github.com/linkease/istore.git;main" >> feeds.conf.default
# 一键上网设置向导 netwizard 源
echo "src-git netwizard https://github.com/sirpdboy/luci-app-netwizard.git;main" >> feeds.conf.default

# 本地导入仓库内定制Edge主题
if [ -d "$GITHUB_WORKSPACE/package/luci-theme-edge-master" ];then
    cp -r "$GITHUB_WORKSPACE/package/luci-theme-edge-master" package/luci-theme-edge
    echo "本地Edge主题已导入"
else
    echo "警告：本地Edge主题文件夹缺失，跳过复制"
fi

# 更新全部feeds
./scripts/feeds update -a
./scripts/feeds install -a

# ========== 【关键】验证istore源是否真的拉取成功 ==========
echo "====== 检查istore源拉取结果 ======"
ls -la feeds/istore/ 2>/dev/null || echo "❌ feeds/istore/ 目录不存在，源拉取失败！"
ls -la package/feeds/istore/ 2>/dev/null || echo "❌ package/feeds/istore/ 目录不存在，install失败！"

# ========== 【补全】强制安装所有关键包，防止漏打包 ==========
# iStore商店 + 强制依赖
./scripts/feeds install luci-app-store
./scripts/feeds install luci-compat

# 上网向导 + 中文包
./scripts/feeds install luci-app-netwizard
./scripts/feeds install luci-i18n-netwizard-zh-cn

# 中文语言包（两个都必须装，缺一个页面半英文）
./scripts/feeds install luci-i18n-zh-cn
./scripts/feeds install luci-i18n-base-zh-cn

# 包管理器全套（iStore底层依赖，绝对不能少）
./scripts/feeds install opkg
./scripts/feeds install opkg-update
./scripts/feeds install opkg-conf

# 网络下载工具 + HTTPS证书
./scripts/feeds install curl wget ca-certificates unzip tar

# ========== 【最终验证】列出所有已安装的关键包 ==========
echo "====== 关键包安装验证 ======"
ls package/feeds/istore/ 2>/dev/null | grep -E "store|compat" || echo "❌ iStore相关包缺失"
ls package/feeds/luci/ 2>/dev/null | grep -E "i18n-zh-cn|i18n-base-zh-cn" || echo "❌ 中文包缺失"

echo "====== diy-part1.sh 执行完毕 ======"
