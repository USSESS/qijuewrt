m = Map("kijue", translate("KiJue 主题设置"), translate("KiJueWrt 主题 - 背景、颜色、透明度"))

s = m:section(NamedSection, "theme", "kijue", translate("外观"))
s.addremove = false

bg = s:option(ListValue, "background", translate("背景模式"))
bg:value("light", translate("浅色渐变（默认）"))
bg:value("dark", translate("深色模式"))
bg:value("image", translate("自定义图片"))
bg:value("solid", translate("纯色"))
bg.default = "light"

c1 = s:option(Value, "bg_color1", translate("渐变起始色"))
c1.datatype = "string"
c1.default = "#dbeafe"
c1:depends("background", "light")

c2 = s:option(Value, "bg_color2", translate("渐变结束色"))
c2.datatype = "string"
c2.default = "#f0f9ff"
c2:depends("background", "light")

img = s:option(Value, "bg_image", translate("背景图片地址"))
img.datatype = "string"
img:depends("background", "image")

ac = s:option(Value, "accent", translate("主题强调色"))
ac.datatype = "string"
ac.default = "#3b82f6"

op = s:option(Value, "card_opacity", translate("卡片透明度 (0-1)"))
op.datatype = "float"
op.default = "0.82"

return m
