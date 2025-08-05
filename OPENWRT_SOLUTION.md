# 🚀 OpenWrt系统解决方案

## 📋 问题分析

您在OpenWrt系统上遇到了两个问题：

1. **`./quick_auto_start.sh: not found`** - 文件不存在
2. **`sudo: not found`** - OpenWrt系统通常不使用sudo

## 🔧 解决方案

### 方法1：使用现有的systemd_service.sh（推荐）

```bash
# 直接运行，无需sudo
./systemd_service.sh install

# 查看状态
./systemd_service.sh status

# 重启服务
./systemd_service.sh restart
```

### 方法2：使用新的OpenWrt专用脚本

我已经为您创建了 `openwrt_quick_setup.sh` 脚本：

```bash
# 给脚本执行权限
chmod +x openwrt_quick_setup.sh

# 安装并启动服务
./openwrt_quick_setup.sh install

# 查看状态
./openwrt_quick_setup.sh status

# 重启服务
./openwrt_quick_setup.sh restart
```

### 方法3：手动设置（最简单）

```bash
# 1. 设置文件权限
chmod +x jk.sh web_editor.py zr.py jx.py zw.py zc.py log.py

# 2. 安装依赖
opkg update
opkg install python3 python3-pip
pip3 install flask

# 3. 创建systemd服务
cat > /etc/systemd/system/openclash-manager-watchdog.service << 'EOF'
[Unit]
Description=OpenClash节点管理系统 - 守护进程
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/OpenClashManage
ExecStart=/bin/bash /root/OpenClashManage/jk.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/openclash-manager-web.service << 'EOF'
[Unit]
Description=OpenClash节点管理系统 - Web编辑器
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/OpenClashManage
ExecStart=/usr/bin/python3 /root/OpenClashManage/web_editor.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 4. 启用并启动服务
systemctl daemon-reload
systemctl enable openclash-manager-watchdog.service
systemctl enable openclash-manager-web.service
systemctl start openclash-manager-watchdog.service
systemctl start openclash-manager-web.service

# 5. 查看状态
systemctl status openclash-manager-watchdog.service
systemctl status openclash-manager-web.service
```

## 📊 服务管理命令

### 使用systemctl（推荐）
```bash
# 启动服务
systemctl start openclash-manager-watchdog.service
systemctl start openclash-manager-web.service

# 停止服务
systemctl stop openclash-manager-watchdog.service
systemctl stop openclash-manager-web.service

# 重启服务
systemctl restart openclash-manager-watchdog.service
systemctl restart openclash-manager-web.service

# 查看状态
systemctl status openclash-manager-watchdog.service
systemctl status openclash-manager-web.service

# 启用开机自启动
systemctl enable openclash-manager-watchdog.service
systemctl enable openclash-manager-web.service

# 禁用开机自启动
systemctl disable openclash-manager-watchdog.service
systemctl disable openclash-manager-web.service
```

### 查看日志
```bash
# 查看服务日志
journalctl -u openclash-manager-watchdog.service -f
journalctl -u openclash-manager-web.service -f

# 查看系统日志
tail -f /var/log/messages
```

## 🔍 验证安装

### 检查进程
```bash
# 查看进程状态
ps aux | grep -E "(web_editor|jk.sh)"

# 查看端口
netstat -tlnp | grep :5000
```

### 检查服务状态
```bash
# 检查systemd服务
systemctl is-active openclash-manager-watchdog.service
systemctl is-active openclash-manager-web.service

# 检查服务是否启用
systemctl is-enabled openclash-manager-watchdog.service
systemctl is-enabled openclash-manager-web.service
```

## 🌐 访问Web界面

### 获取IP地址
```bash
# 获取路由器IP
hostname -I
ip addr show
```

### 访问Web编辑器
- 在浏览器中输入：`http://你的路由器IP:5000`
- 例如：`http://192.168.1.1:5000`

## 🔧 故障排除

### 常见问题

#### 1. 服务启动失败
```bash
# 检查依赖
python3 --version
pip3 --version

# 检查文件权限
ls -la /root/OpenClashManage/

# 检查端口占用
netstat -tlnp | grep :5000
```

#### 2. 开机不自动启动
```bash
# 检查服务是否启用
systemctl is-enabled openclash-manager-watchdog.service
systemctl is-enabled openclash-manager-web.service

# 重新启用服务
systemctl enable openclash-manager-watchdog.service
systemctl enable openclash-manager-web.service
```

#### 3. 权限问题
```bash
# 确保脚本有执行权限
chmod +x /root/OpenClashManage/*.sh
chmod +x /root/OpenClashManage/*.py

# 检查用户权限
whoami
id
```

#### 4. 端口冲突
```bash
# 检查端口占用
lsof -i :5000

# 修改端口（编辑web_editor.py）
nano /root/OpenClashManage/web_editor.py
# 修改 app.run(host='0.0.0.0', port=5000) 中的端口号
```

## 📈 性能监控

### 资源使用
```bash
# 监控CPU和内存使用
top -p $(pgrep -f "web_editor\|jk.sh")

# 监控磁盘使用
df -h

# 监控网络连接
netstat -an | grep :5000
```

## 🔒 安全配置

### 防火墙设置
```bash
# 开放Web编辑器端口
iptables -A INPUT -p tcp --dport 5000 -j ACCEPT

# 保存防火墙规则
iptables-save > /etc/config/firewall
```

### 访问控制
```bash
# 限制访问IP（在web_editor.py中修改）
# app.run(host='0.0.0.0', port=5000) 改为
# app.run(host='127.0.0.1', port=5000)
```

## 📞 技术支持

### 获取帮助
```bash
# 查看脚本帮助
./openwrt_quick_setup.sh help

# 查看服务状态
./openwrt_quick_setup.sh status

# 查看详细日志
journalctl -u openclash-manager-watchdog.service -f
```

### 问题反馈
- 检查服务状态：`systemctl status openclash-manager-*.service`
- 查看错误日志：`journalctl -u openclash-manager-*.service -e`
- 重启服务：`systemctl restart openclash-manager-*.service`

---

**总结**：推荐使用 `./systemd_service.sh install` 或 `./openwrt_quick_setup.sh install` 来设置自动启动，无需使用sudo。这些脚本专门为OpenWrt系统优化，会自动处理权限和依赖问题。 