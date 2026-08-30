-- KiJueWrt Theme 控制器
module("luci.controller.kijue", package.seeall)

function index()
    local page

    -- 6大页面
    page = entry({"admin", "kijue", "dashboard"}, template("themes/kijue/dashboard"), _("首页"), 1)
    page.dependent = false; page.i18n = "base"

    page = entry({"admin", "kijue", "network"}, template("themes/kijue/network"), _("网络"), 2)
    page.dependent = false; page.i18n = "base"

    page = entry({"admin", "kijue", "devices"}, template("themes/kijue/devices"), _("设备"), 3)
    page.dependent = false; page.i18n = "base"

    page = entry({"admin", "kijue", "apps"}, template("themes/kijue/apps"), _("应用"), 4)
    page.dependent = false; page.i18n = "base"

    page = entry({"admin", "kijue", "system"}, template("themes/kijue/system"), _("系统"), 5)
    page.dependent = false; page.i18n = "base"

    -- 主题设置
    page = entry({"admin", "system", "kijue"}, cbi("kijue/config"), _("KiJue 主题设置"), 93)
    page.dependent = false; page.i18n = "base"

    -- 数据 API
    page = entry({"kijue", "data"}, call("action_data"), nil)
    page.leaf = true
end

function is_installed(pkg)
    local fs = require "nixio.fs"
    local status = fs.readfile("/usr/lib/opkg/status")
    if status then
        for line in status:gmatch("[^\r\n]+") do
            if line == "Package: " .. pkg then return true end
        end
    end
    local bins = {
        ["istore"]="/usr/bin/istore", ["speedtest"]="/usr/bin/speedtest",
        ["nlbwmon"]="/usr/sbin/nlbwmon", ["adguardhome"]="/usr/bin/AdGuardHome",
        ["mosdns"]="/usr/bin/mosdns", ["ddns"]="/usr/lib/ddns/dynamic_dns_updater.sh",
        ["docker"]="/usr/bin/docker", ["frpc"]="/usr/bin/frpc",
        ["zerotier"]="/usr/bin/zerotier-cli", ["wireguard"]="/usr/bin/wg",
        ["openclash"]="/usr/share/openclash/openclash.sh", ["passwall"]="/usr/share/passwall/rule_update.sh",
        ["ssrplus"]="/usr/share/shadowsocksr/ssrplus", ["vssr"]="/usr/share/vssr/version",
        ["unblockneteasemusic"]="/usr/share/UnblockNeteaseMusic/app.js",
        ["aliyundrive"]="/usr/bin/aliyundrive-webdav", ["jellyfin"]="/usr/bin/jellyfin",
        ["transmission"]="/usr/bin/transmission-daemon", ["qbittorrent"]="/usr/bin/qbittorrent-nox",
        ["aria2"]="/usr/bin/aria2c", ["samba4"]="/usr/sbin/smbd",
        ["vsftpd"]="/usr/sbin/vsftpd", ["minidlna"]="/usr/sbin/minidlnad",
        ["kms"]="/usr/bin/vlmcsd", ["unbound"]="/usr/sbin/unbound",
        ["sqm"]="/usr/lib/sqm/start-sqm", ["mwan3"]="/usr/sbin/mwan3",
        ["udpxy"]="/usr/bin/udpxy", ["upnp"]="/usr/sbin/miniupnpd",
        ["etherwake"]="/usr/bin/etherwake", ["wol"]="/usr/bin/wol",
    }
    if bins[pkg] and fs.access(bins[pkg]) then return true end
    return false
end

function is_running(proc)
    local util = require "luci.util"
    local r = util.exec("pgrep -f '" .. proc .. "' 2>/dev/null | head -1")
    return r and #r > 0
end

function action_data()
    local http = require "luci.http"
    local sys = require "luci.sys"
    local fs = require "nixio.fs"
    local d = {}

    d.hostname = sys.hostname()
    d.model = sys.sysinfo()["model"] or "Unknown"
    d.uptime = sys.uptime()
    d.memory = sys.sysinfo()["memory"] or {}

    local cpu_usage = 0
    local stat = fs.readfile("/proc/stat")
    if stat then
        local line = stat:match("^cpu%s+([^\n]+)")
        if line then
            local nums = {}
            for n in line:gmatch("%d+") do table.insert(nums, tonumber(n)) end
            if #nums >= 4 then
                local idle = nums[4]
                local total = 0
                for _, v in ipairs(nums) do total = total + v end
                cpu_usage = math.floor((1 - idle / total) * 100)
            end
        end
    end
    d.cpu_usage = cpu_usage
    d.cpu_cores = tonumber(sys.exec("nproc 2>/dev/null") or "1") or 1

    local mt = d.memory.total or 0
    local mf = d.memory.free or 0
    local mb = d.memory.buffered or 0
    local mu = mt - mf - mb
    d.mem_usage = mt > 0 and math.floor(mu / mt * 100) or 0
    d.mem_total_mb = math.floor(mt / 1024)
    d.mem_used_mb = math.floor(mu / 1024)

    local arp = fs.readfile("/proc/net/arp") or ""
    local dev_count = 0
    local dev_list = {}
    for line in arp:gmatch("[^\r\n]+") do
        if not line:match("^IP") then
            local ip, hw = line:match("^(%S+)%s+%S+%s+%S+%s+(%S+)")
            if hw and hw ~= "00:00:00:00:00:00" then
                dev_count = dev_count + 1
                table.insert(dev_list, {ip=ip, mac=hw})
            end
        end
    end
    d.online_devices = dev_count
    d.device_list = dev_list

    local conn = 0
    local nf = fs.readfile("/proc/sys/net/netfilter/nf_conntrack_count")
    if nf then conn = tonumber(nf:match("%d+")) or 0 end
    d.active_connections = conn

    d.interfaces = {}
    d.wan_rx = 0
    d.wan_tx = 0
    for _, iface in ipairs({"br-lan", "eth0", "eth1", "wan", "wwan", "wlan0", "wlan1"}) do
        local path = "/sys/class/net/" .. iface
        if fs.access(path) then
            local op = fs.readfile(path .. "/operstate") or "down"
            op = op:gsub("%s+", "")
            local ip = sys.exec("ip -4 addr show " .. iface .. " 2>/dev/null | grep 'inet ' | awk '{print $2}' | head -1"):gsub("%s+", "")
            local rx = tonumber(fs.readfile(path .. "/statistics/rx_bytes")) or 0
            local tx = tonumber(fs.readfile(path .. "/statistics/tx_bytes")) or 0
            table.insert(d.interfaces, {name=iface, up=op=="up", ip=ip, rx_bytes=rx, tx_bytes=tx})
            if iface == "wan" or iface == "eth1" then
                d.wan_rx = rx; d.wan_tx = tx
            end
        end
    end

    d.wifi_signal = 75 + math.floor(math.random() * 20)

    -- 全部已安装应用
    d.apps = {}
    local app_list = {
        {id="istore",name="应用商店",desc="软件包管理",icon="store",url="/cgi-bin/luci/admin/store",cat="apps"},
        {id="speedtest",name="网速测试",desc="带宽测速",icon="speed",url="/cgi-bin/luci/admin/nlbw/speedtest",cat="devices"},
        {id="nlbwmon",name="流量监控",desc="带宽统计",icon="chart",url="/cgi-bin/luci/admin/nlbw/display",cat="devices"},
        {id="adguardhome",name="AdGuard Home",desc="广告过滤DNS",icon="shield",url="/cgi-bin/luci/admin/services/adguardhome",cat="apps"},
        {id="mosdns",name="MosDNS",desc="DNS分流",icon="dns",url="/cgi-bin/luci/admin/services/mosdns",cat="network"},
        {id="ddns",name="动态DNS",desc="DDNS",icon="ddns",url="/cgi-bin/luci/admin/services/ddns",cat="network"},
        {id="docker",name="Docker",desc="容器管理",icon="docker",url="/cgi-bin/luci/admin/docker",cat="apps"},
        {id="frpc",name="Frp内网穿透",desc="内网穿透",icon="frp",url="/cgi-bin/luci/admin/services/frpc",cat="network"},
        {id="zerotier",name="ZeroTier",desc="虚拟局域网",icon="vpn",url="/cgi-bin/luci/admin/vpn/zerotier",cat="network"},
        {id="wireguard",name="WireGuard",desc="VPN隧道",icon="vpn",url="/cgi-bin/luci/admin/network/wireguard",cat="network"},
        {id="openclash",name="OpenClash",desc="代理工具",icon="proxy",url="/cgi-bin/luci/admin/services/openclash",cat="apps"},
        {id="passwall",name="PassWall",desc="代理工具",icon="proxy",url="/cgi-bin/luci/admin/services/passwall",cat="apps"},
        {id="ssrplus",name="ShadowSocksR",desc="代理工具",icon="proxy",url="/cgi-bin/luci/admin/services/shadowsocksr",cat="apps"},
        {id="vssr",name="Hello World",desc="代理工具",icon="proxy",url="/cgi-bin/luci/admin/vssr",cat="apps"},
        {id="unblockneteasemusic",name="网易云解锁",desc="音乐解锁",icon="music",url="/cgi-bin/luci/admin/services/unblockneteasemusic",cat="apps"},
        {id="aliyundrive",name="阿里云盘",desc="WebDAV",icon="cloud",url="/cgi-bin/luci/admin/services/aliyundrive",cat="apps"},
        {id="jellyfin",name="Jellyfin",desc="媒体服务器",icon="media",url="/cgi-bin/luci/admin/services/jellyfin",cat="apps"},
        {id="transmission",name="Transmission",desc="BT下载",icon="download",url="/cgi-bin/luci/admin/services/transmission",cat="apps"},
        {id="qbittorrent",name="qBittorrent",desc="BT下载",icon="download",url="/cgi-bin/luci/admin/services/qbittorrent",cat="apps"},
        {id="aria2",name="Aria2",desc="下载工具",icon="download",url="/cgi-bin/luci/admin/services/aria2",cat="apps"},
        {id="samba4",name="网络共享",desc="Samba",icon="share",url="/cgi-bin/luci/admin/nas/samba",cat="apps"},
        {id="vsftpd",name="FTP服务器",desc="文件传输",icon="ftp",url="/cgi-bin/luci/admin/services/vsftpd",cat="apps"},
        {id="minidlna",name="DLNA媒体",desc="媒体共享",icon="media",url="/cgi-bin/luci/admin/services/minidlna",cat="apps"},
        {id="kms",name="KMS服务器",desc="系统激活",icon="key",url="/cgi-bin/luci/admin/services/kms",cat="apps"},
        {id="unbound",name="Unbound",desc="DNS递归",icon="dns",url="/cgi-bin/luci/admin/services/unbound",cat="network"},
        {id="sqm",name="SQM QoS",desc="流量整形",icon="qos",url="/cgi-bin/luci/admin/network/sqm",cat="network"},
        {id="mwan3",name="多线多拨",desc="负载均衡",icon="mwan",url="/cgi-bin/luci/admin/network/multiwan",cat="network"},
        {id="udpxy",name="UDPXY",desc="组播转单播",icon="tv",url="/cgi-bin/luci/admin/services/udpxy",cat="network"},
        {id="upnp",name="UPnP",desc="端口映射",icon="upnp",url="/cgi-bin/luci/admin/network/upnp",cat="network"},
    }
    -- 预设应用（带精美图标和描述）
    local preset_ids = {}
    for _, app in ipairs(app_list) do
        if is_installed(app.id) then
            app.running = is_running(app.id)
            table.insert(d.apps, app)
            preset_ids[app.id] = true
        end
    end

    -- 动态扫描 LuCI 菜单树，自动发现新装的插件
    local ok_disp, disp = pcall(require, "luci.dispatcher")
    if ok_disp and disp.node then
        local root = disp.node()
        if root and root.children and root.children.admin then
            local function scan_node(node, path, depth)
                if not node or not node.children then return end
                for name, child in pairs(node.children) do
                    local cur_path = path .. "/" .. name
                    -- 跳过我们自己的页面和纯分类节点
                    if name ~= "kijue" and depth < 4 then
                        -- 有实际页面且有标题的节点
                        if child.target and child.title and not child.hidden then
                            local title = tostring(child.title)
                            -- 跳过基础系统页面（已在导航或基础卡片里）
                            local skip = {
                                ["overview"]=true, ["routes"]=true, ["syslog"]=true,
                                ["dmesg"]=true, ["processes"]=true, ["realtime"]=true,
                                ["connections"]=true, ["load"]=true, ["iptables"]=true,
                                ["system"]=true, ["admin"]=true, ["password"]=true,
                                ["sshkeys"]=true, ["packages"]=true, ["opkg"]=true,
                                ["startup"]=true, ["crontab"]=true, ["leds"]=true,
                                ["flashops"]=true, ["backup"]=true, ["reboot"]=true,
                                ["commands"]=true, ["logs"]=true,
                            }
                            if not skip[name] and not preset_ids[name] then
                                -- 判断分类
                                local cat = "apps"
                                if path:match("/network$") or path:match("/vpn$") then cat = "network"
                                elseif path:match("/status$") then cat = "devices"
                                elseif path:match("/nas$") then cat = "apps"
                                end
                                -- 生成 URL
                                local url = "/cgi-bin/luci" .. cur_path
                                table.insert(d.apps, {
                                    id = name,
                                    name = title,
                                    desc = "自动发现",
                                    icon = "default",
                                    url = url,
                                    cat = cat,
                                    auto = true
                                })
                            end
                        end
                        scan_node(child, cur_path, depth + 1)
                    end
                end
            end
            scan_node(root.children.admin, "/admin", 1)
        end
    end

    -- 主题配置
    local uci = require "luci.model.uci".cursor()
    d.theme = {
        background = uci:get("kijue", "theme", "background") or "light",
        bg_color1 = uci:get("kijue", "theme", "bg_color1") or "#dbeafe",
        bg_color2 = uci:get("kijue", "theme", "bg_color2") or "#f0f9ff",
        bg_image = uci:get("kijue", "theme", "bg_image") or "",
        accent = uci:get("kijue", "theme", "accent") or "#3b82f6",
        card_opacity = uci:get("kijue", "theme", "card_opacity") or "0.82",
    }

    http.prepare_content("application/json")
    http.write_json(d)
end
