/* ============================================
   KiJueWrt Theme - 核心 JS（多页面）
   ============================================ */

var KiJueTheme = (function() {
    'use strict';

    var ICONS = {
        store: '&#128230;', speed: '&#128640;', chart: '&#128202;',
        shield: '&#128737;', dns: '&#127760;', ddns: '&#128273;',
        docker: '&#128021;', frp: '&#128271;', vpn: '&#128274;',
        proxy: '&#127760;', music: '&#127925;', cloud: '&#9729;',
        media: '&#127916;', download: '&#11015;', share: '&#128228;',
        ftp: '&#128190;', key: '&#128273;', qos: '&#9881;',
        mwan: '&#128257;', tv: '&#128250;', upnp: '&#128268;',
        default: '&#9670;'
    };

    var DEVICE_TYPES = [
        { icon: '&#128187;', label: '笔记本' },
        { icon: '&#128241;', label: '手机' },
        { icon: '&#128250;', label: '电视' },
        { icon: '&#127918;', label: '游戏机' },
        { icon: '&#128190;', label: '硬盘' },
        { icon: '&#128225;', label: '平板' },
        { icon: '&#9203;', label: '手表' },
        { icon: '&#127911;', label: '耳机' },
        { icon: '&#128421;', label: '台式机' },
        { icon: '&#128221;', label: '打印机' },
    ];

    var lastWan = { rx: 0, tx: 0, time: 0 };
    var RING_C = 2 * Math.PI * 55;
    var currentPage = 'dashboard';

    function init(page) {
        currentPage = page || 'dashboard';
        fetchData();
        setInterval(fetchData, 5000);
    }

    function fetchData() {
        fetch('/cgi-bin/luci/kijue/data', {
            credentials: 'same-origin',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(function(r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(function(d) {
            if (d.theme) applyTheme(d.theme);
            if (currentPage === 'dashboard') renderDashboard(d);
            if (currentPage === 'network') renderNetwork(d);
            if (currentPage === 'devices') renderDevices(d);
            if (currentPage === 'apps') renderApps(d);
            if (currentPage === 'system') renderSystem(d);
        })
        .catch(function(e) { console.warn('KiJueWrt:', e.message); });
    }

    function applyTheme(theme) {
        var root = document.documentElement;
        var body = document.body;
        if (theme.accent) {
            root.style.setProperty('--kijue-accent', theme.accent);
            root.style.setProperty('--kijue-accent2', lighten(theme.accent, 30));
        }
        if (theme.card_opacity) {
            var op = parseFloat(theme.card_opacity);
            if (op >= 0 && op <= 1) root.style.setProperty('--kijue-card', 'rgba(255,255,255,' + op + ')');
        }
        body.classList.remove('kijue-dark', 'kijue-image');
        if (theme.background === 'dark') body.classList.add('kijue-dark');
        else if (theme.background === 'image' && theme.bg_image) {
            root.style.setProperty('--kijue-bg-image', 'url("' + theme.bg_image + '")');
            body.classList.add('kijue-image');
        }
    }

    function renderDashboard(d) {
        var devices = d.online_devices || 0;
        var pct = Math.min(devices / 30, 1);
        var ring = document.getElementById('kijue-ring');
        if (ring) ring.style.strokeDashoffset = RING_C * (1 - pct);

        setText('kijue-ring-status', d.wan_rx > 0 ? '网络正常' : '检测中');
        setText('kijue-ring-uptime', '运行 ' + formatUptime(d.uptime || 0));
        setText('kijue-devices', devices);
        setText('kijue-uptime', formatUptime(d.uptime || 0));
        setText('kijue-conns', d.active_connections != null ? d.active_connections : '--');
        setText('kijue-cpu', (d.cpu_usage != null ? d.cpu_usage : '--') + '%');
        setText('kijue-signal', d.wifi_signal || '--');

        renderTopology(devices);
        renderAppGrid('kijue-apps', (d.apps || []).slice(0, 8), 'kijue-apps-count');
        calcRate(d);
    }

    function renderNetwork(d) {
        var netApps = (d.apps || []).filter(function(a) { return a.cat === 'network'; });
        renderAppGrid('kijue-net-apps', netApps, 'kijue-net-apps-count');

        var el = document.getElementById('kijue-interfaces');
        if (el && d.interfaces && d.interfaces.length > 0) {
            var html = '';
            d.interfaces.forEach(function(v) {
                html += '<div class="kijue-card kijue-func-card" style="cursor:default;">' +
                    '<div class="kijue-func-icon" style="background:' + (v.up ? 'linear-gradient(135deg,#d1fae5,#a7f3d0)' : 'linear-gradient(135deg,#fee2e2,#fecaca)') + ';color:' + (v.up ? '#10b981' : '#ef4444') + ';">' +
                        (v.up ? '&#9989;' : '&#10060;') + '</div>' +
                    '<div class="kijue-func-name">' + esc(v.name) + '</div>' +
                    '<div class="kijue-func-desc">' + esc(v.ip || (v.up ? 'DHCP...' : '未连接')) + '</div>' +
                '</div>';
            });
            el.innerHTML = html;
        }
    }

    function renderDevices(d) {
        var count = d.online_devices || 0;
        setText('kijue-dev-count', count);
        setWidth('kijue-dev-bar', Math.min(count / 50 * 100, 100));
        setText('kijue-conn-count', d.active_connections || '--');
        setWidth('kijue-conn-bar', Math.min((d.active_connections || 0) / 2000 * 100, 100));

        calcRate(d);

        var list = document.getElementById('kijue-device-list');
        if (list && d.device_list && d.device_list.length > 0) {
            setText('kijue-device-list-count', d.device_list.length);
            var html = '';
            d.device_list.forEach(function(dev, i) {
                var type = DEVICE_TYPES[i % DEVICE_TYPES.length];
                html += '<div class="kijue-card kijue-device-item">' +
                    '<div class="kijue-device-avatar">' + type.icon + '</div>' +
                    '<div class="kijue-device-meta">' +
                        '<div class="kijue-device-ip">' + esc(dev.ip) + '</div>' +
                        '<div class="kijue-device-mac">' + esc(dev.mac) + '</div>' +
                    '</div>' +
                '</div>';
            });
            list.innerHTML = html;
        } else if (list) {
            list.innerHTML = '<div class="kijue-empty" style="grid-column:1/-1;"><div class="kijue-empty-icon">&#128187;</div><p>暂无在线设备</p></div>';
        }
    }

    function renderApps(d) {
        var apps = d.apps || [];
        renderAppGrid('kijue-all-apps', apps, 'kijue-all-apps-count');

        var proxy = apps.filter(function(a) {
            return a.id === 'openclash' || a.id === 'passwall' || a.id === 'ssrplus' ||
                   a.id === 'vssr' || a.id === 'zerotier' || a.id === 'wireguard' || a.id === 'frpc';
        });
        renderAppGrid('kijue-proxy-apps', proxy, 'kijue-proxy-count');

        var media = apps.filter(function(a) {
            return a.id === 'transmission' || a.id === 'qbittorrent' || a.id === 'aria2' ||
                   a.id === 'jellyfin' || a.id === 'minidlna' || a.id === 'aliyundrive' ||
                   a.id === 'unblockneteasemusic' || a.id === 'samba4' || a.id === 'vsftpd';
        });
        renderAppGrid('kijue-media-apps', media, 'kijue-media-count');
    }

    function renderSystem(d) {
        setText('kijue-sys-cpu', (d.cpu_usage != null ? d.cpu_usage : '--') + '%');
        setWidth('kijue-sys-cpu-bar', d.cpu_usage || 0);
        setText('kijue-sys-cpu-model', (d.model || '--') + (d.cpu_cores ? ' · ' + d.cpu_cores + '核' : ''));

        setText('kijue-sys-mem', (d.mem_usage != null ? d.mem_usage : '--') + '%');
        setWidth('kijue-sys-mem-bar', d.mem_usage || 0);
        var memText = '--';
        if (d.mem_total_mb) memText = (d.mem_used_mb || 0) + ' / ' + d.mem_total_mb + ' MB';
        setText('kijue-sys-mem-model', memText);

        setText('kijue-sys-uptime', formatUptime(d.uptime || 0));
        setText('kijue-sys-model', '设备: ' + (d.model || '--') + ' | 主机名: ' + (d.hostname || '--'));
    }

    function renderTopology(deviceCount) {
        var el = document.getElementById('kijue-topology');
        if (!el) return;
        var floor = el.querySelector('.kijue-topology-floor');
        el.innerHTML = '';
        if (floor) el.appendChild(floor);

        var count = Math.min(deviceCount || 6, 10);
        if (count < 4) count = 4;
        var positions = [
            { left: '8%', bottom: '26px', delay: '0s' },
            { left: '22%', bottom: '44px', delay: '0.3s' },
            { left: '38%', bottom: '22px', delay: '0.6s' },
            { left: '52%', bottom: '40px', delay: '0.9s' },
            { left: '66%', bottom: '26px', delay: '1.2s' },
            { left: '80%', bottom: '44px', delay: '1.5s' },
            { left: '15%', bottom: '60px', delay: '0.4s' },
            { left: '45%', bottom: '56px', delay: '0.8s' },
            { left: '72%', bottom: '60px', delay: '1.1s' },
            { left: '90%', bottom: '30px', delay: '1.4s' },
        ];
        for (var i = 0; i < count; i++) {
            var pos = positions[i % positions.length];
            var dev = DEVICE_TYPES[i % DEVICE_TYPES.length];
            var div = document.createElement('div');
            div.className = 'kijue-device';
            div.style.left = pos.left;
            div.style.bottom = pos.bottom;
            div.style.animationDelay = pos.delay;
            div.innerHTML = '<div class="kijue-device-icon">' + dev.icon + '</div>' +
                '<div class="kijue-device-label">' + dev.label + '</div>';
            el.appendChild(div);
        }
    }

    function guessIcon(name) {
        if (!name) return ICONS.default;
        var n = name.toLowerCase();
        if (n.match(/clash|passwall|ssr|shadow|vpn|proxy|v2ray|xray/)) return ICONS.proxy;
        if (n.match(/dns|adguard|mosdns|unbound/)) return ICONS.dns;
        if (n.match(/docker|container/)) return ICONS.docker;
        if (n.match(/download|transmission|qbittorrent|aria2|bt|torrent/)) return ICONS.download;
        if (n.match(/media|jellyfin|dlna|plex|emby|video|tv/)) return ICONS.media;
        if (n.match(/music|netease|audio/)) return ICONS.music;
        if (n.match(/cloud|drive|webdav|aliyun|baidu/)) return ICONS.cloud;
        if (n.match(/share|samba|smb|ftp|nfs/)) return ICONS.share;
        if (n.match(/frp|穿透|zerotier|wireguard|tailscale/)) return ICONS.frp;
        if (n.match(/ddns|动态/)) return ICONS.ddns;
        if (n.match(/qos|流量|整形|sqm/)) return ICONS.qos;
        if (n.match(/mwan|多拨|负载/)) return ICONS.mwan;
        if (n.match(/kms|激活/)) return ICONS.key;
        if (n.match(/store|商店|软件|package/)) return ICONS.store;
        if (n.match(/speed|测速|speedtest/)) return ICONS.speed;
        if (n.match(/chart|流量|监控|nlbw|统计/)) return ICONS.chart;
        if (n.match(/shield|广告|过滤|adblock/)) return ICONS.shield;
        if (n.match(/upnp/)) return ICONS.upnp;
        return ICONS.default;
    }

    function renderAppGrid(gridId, apps, countId) {
        var grid = document.getElementById(gridId);
        if (!grid) return;
        if (countId) setText(countId, apps.length);

        if (!apps || apps.length === 0) {
            grid.innerHTML = '<div class="kijue-empty" style="grid-column:1/-1;"><div class="kijue-empty-icon">&#128230;</div><p>暂无应用，去应用商店安装吧</p></div>';
            return;
        }

        var html = '';
        apps.forEach(function(app) {
            var icon = app.auto ? guessIcon(app.name) : (ICONS[app.icon] || ICONS.default);
            var status = '';
            if (typeof app.running !== 'undefined') {
                status = '<div class="kijue-func-status ' + (app.running ? 'on' : '') + '"></div>';
            }
            var autoBadge = app.auto ? '<div style="position:absolute;top:12px;left:12px;font-size:9px;background:rgba(59,130,246,0.1);color:var(--kijue-accent);padding:1px 6px;border-radius:6px;">NEW</div>' : '';
            html += '<a class="kijue-card kijue-func-card" href="' + app.url + '">' +
                status + autoBadge +
                '<div class="kijue-func-icon">' + icon + '</div>' +
                '<div class="kijue-func-name">' + esc(app.name) + '</div>' +
                '<div class="kijue-func-desc">' + esc(app.desc || '') + '</div>' +
            '</a>';
        });
        grid.innerHTML = html;
    }

    function calcRate(d) {
        var now = Date.now();
        if (lastWan.time > 0) {
            var dt = (now - lastWan.time) / 1000;
            if (dt > 0) {
                var rx = ((d.wan_rx - lastWan.rx) / dt * 8 / 1000000).toFixed(0);
                var tx = ((d.wan_tx - lastWan.tx) / dt * 8 / 1000000).toFixed(0);
                if (rx < 0) rx = 0;
                if (tx < 0) tx = 0;
                setText('kijue-download', rx);
                setText('kijue-upload', tx);
                setText('kijue-dl-rate', rx + ' Mbps');
                setWidth('kijue-dl-bar', Math.min(rx / 1000 * 100, 100));
            }
        }
        lastWan.rx = d.wan_rx || 0;
        lastWan.tx = d.wan_tx || 0;
        lastWan.time = now;
    }

    function setText(id, v) { var e = document.getElementById(id); if (e) e.textContent = v; }
    function setWidth(id, pct) { var e = document.getElementById(id); if (e) e.style.width = Math.min(100, Math.max(0, pct)) + '%'; }
    function esc(s) {
        if (s == null) return '';
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }
    function formatUptime(sec) {
        if (!sec || sec <= 0) return '--';
        var d = Math.floor(sec / 86400), h = Math.floor((sec % 86400) / 3600), m = Math.floor((sec % 3600) / 60);
        if (d > 0) return d + '天' + h + '时';
        if (h > 0) return h + '时' + m + '分';
        return m + '分';
    }
    function lighten(hex, pct) {
        hex = hex.replace('#', '');
        if (hex.length === 3) hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
        var n = parseInt(hex, 16);
        var r = Math.min(255, (n >> 16) + Math.round(255 * pct / 100));
        var g = Math.min(255, ((n >> 8) & 0xff) + Math.round(255 * pct / 100));
        var b = Math.min(255, (n & 0xff) + Math.round(255 * pct / 100));
        return '#' + ((r << 16) | (g << 8) | b).toString(16).padStart(6, '0');
    }

    return { init: init, fetchData: fetchData };
})();
