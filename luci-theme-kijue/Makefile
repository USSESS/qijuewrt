#
# luci-theme-kijue - KiJueWrt 主题
#
include $(TOPDIR)/rules.mk

PKG_NAME:=luci-theme-kijue
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_MAINTAINER:=KiJueWrt
PKG_LICENSE:=Apache-2.0

include $(INCLUDE_DIR)/package.mk

define Package/luci-theme-kijue
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=Themes
  TITLE:=KiJueWrt Theme - 完整多页面主题
  DEPENDS:=+luci-base
  PKGARCH:=all
endef

define Package/luci-theme-kijue/description
  KiJueWrt Theme - 完整多页面 LuCI 主题
  - 6大页面：首页/网络/设备/应用/系统/终端
  - 每个页面卡片式功能入口
  - 应用随已安装软件动态显示
  - 3D路由器首页 + 设备拓扑图
  - 背景可自定义
  - 安装即用，自动设为默认主题
endef

define Build/Compile
endef

define Package/luci-theme-kijue/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/*.lua $(1)/usr/lib/lua/luci/controller/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/kijue
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/kijue/*.lua $(1)/usr/lib/lua/luci/model/cbi/kijue/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/themes/kijue
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/view/themes/kijue/*.htm $(1)/usr/lib/lua/luci/view/themes/kijue/

	$(INSTALL_DIR) $(1)/www/luci-static/kijue/css
	$(INSTALL_DATA) ./files/www/luci-static/kijue/css/*.css $(1)/www/luci-static/kijue/css/

	$(INSTALL_DIR) $(1)/www/luci-static/kijue/js
	$(INSTALL_DATA) ./files/www/luci-static/kijue/js/*.js $(1)/www/luci-static/kijue/js/

	$(INSTALL_DIR) $(1)/www/luci-static/kijue/img
	$(INSTALL_DATA) ./files/www/luci-static/kijue/img/* $(1)/www/luci-static/kijue/img/ 2>/dev/null || true

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/* $(1)/etc/uci-defaults/
endef

$(eval $(call BuildPackage,luci-theme-kijue))
