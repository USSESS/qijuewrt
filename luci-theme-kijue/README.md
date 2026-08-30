# KiJueWrt Theme - OpenWrt 完整多页面主题

一套专为 OpenWrt/LuCI 打造的现代卡片式主题，品牌名 **KiJueWrt**。顶部导航包含 **首页 / 网络 / 设备 / 应用 / 系统 / 终端** 六大入口，每个页面用卡片式"小框框"展示功能入口，应用卡片根据已安装软件**动态出现**，背景可自定义。

## ✨ 特性

- **6 大页面**：首页、网络、设备、应用、系统、终端，点击导航切换
- **动态应用**：自动检测 28+ 种常用软件，已安装的才显示对应卡片
- **3D 路由器**：首页 CSS 3D 路由器模型 + WiFi 信号波动画 + 大圆环状态
- **设备拓扑**：透视网格地板 + 浮动设备图标
- **实时数据**：CPU、内存、在线设备、活动连接、上下行速率，5 秒自动刷新
- **自定义背景**：浅色 / 深色 / 自定义图片，主题色、卡片透明度可调
- **毛玻璃卡片**：backdrop-filter 半透明 + 渐变光斑背景
- **响应式**：手机 / 平板 / 桌面自适应

## 📁 目录结构

```
luci-theme-kijue/
├── Makefile                              # OpenWrt 编译包
├── files/
│   ├── etc/uci-defaults/90-luci-theme-kijue   # 自动设为默认主题
│   └── usr/lib/lua/luci/
│       ├── controller/kijue.lua          # 控制器（6页面+数据API+软件检测）
│       ├── model/cbi/kijue/config.lua    # 主题设置页
│       └── view/themes/kijue/
│           ├── header.htm                # 顶部导航（当前页高亮）
│           ├── footer.htm
│           ├── css.htm
│           ├── dashboard.htm             # 首页
│           ├── network.htm               # 网络页
│           ├── devices.htm               # 设备页
│           ├── apps.htm                  # 应用页
│           └── system.htm                # 系统页
│   └── www/luci-static/kijue/
│       ├── css/kijue.css
│       ├── js/kijue.js
│       └── img/                          # 放自定义背景图
└── preview.html                          # 本地预览（可切换页面）
```

## 🚀 GitHub 云编译使用方法

### 方法一：作为软件包源码编译（推荐）

1. 把整个 `luci-theme-kijue` 文件夹上传到你的 GitHub 仓库
2. 在你的 OpenWrt 编译仓库的 `.config` 或 `feeds.conf` 中添加：
   ```
   src-git kijue https://github.com/你的用户名/luci-theme-kijue.git;main
   ```
3. 编译时选中：
   ```
   LuCI → Themes → luci-theme-kijue
   ```
4. 编译完成刷入固件，登录后自动使用 KiJueWrt 主题

### 方法二：直接放到 package 目录

1. 把 `luci-theme-kijue` 文件夹复制到 OpenWrt 源码的 `package/` 目录下
2. `make menuconfig` 选中 `luci-theme-kijue`
3. `make package/luci-theme-kijue/compile V=s` 单独编译

## 🎨 自定义背景

### 方式一：后台设置（推荐）

登录 LuCI → 系统 → KiJue 主题设置，可调整：
- 背景模式：浅色 / 深色 / 自定义图片
- 主题色（主色调）
- 卡片透明度
- 自定义背景图 URL

### 方式二：放本地图片

把背景图命名为 `bg.jpg` 放到：
```
/www/luci-static/kijue/img/bg.jpg
```
然后在主题设置里背景模式选"自定义图片"，背景图地址填：
```
/luci-static/kijue/img/bg.jpg
```

## 📦 自动检测的软件（28+）

| 分类 | 软件 |
|------|------|
| 应用 | 应用商店(iStore)、Docker、AdGuard Home、OpenClash、PassWall、SSR+、Hello World、网易云解锁、阿里云盘、Jellyfin、Transmission、qBittorrent、Aria2、网络共享(Samba)、FTP、DLNA、KMS |
| 网络 | MosDNS、动态DNS、Frp穿透、ZeroTier、WireGuard、Unbound、SQM QoS、多线多拨、UDPXY、UPnP |
| 设备 | 网速测试、流量监控 |

安装以上任意软件，对应卡片会**自动出现在相应页面**，无需手动配置。

## 🔧 终端页

导航中的"终端"直接跳转到 LuCI 原生命令行页面（`/admin/system/commands`）。
如需网页终端，可安装 `ttyd` 软件包，安装后自动支持。

## 🖥️ 本地预览

直接用浏览器打开 `preview.html`，点击顶部导航切换 5 个页面查看效果（数据为模拟数据）。

## 📝 版本

v1.0.0 - 完整多页面版本
