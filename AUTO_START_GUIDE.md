# 🚀 OpenClash节点管理系统 - 自动启动完整指南

## 📋 概述

本指南将详细介绍如何为OpenClash节点管理系统设置自动启动，包括多种方法和不同系统的配置。

## 🔧 自动启动方法

### 方法1：使用systemd服务（推荐）

#### 1.1 快速安装
```bash
# 下载并运行快速安装脚本
wget -O - https://raw.githubusercontent.com/kuku0799/5000/main/auto_start.sh | bash

# 或者直接运行
chmod +x auto_start.sh
./auto_start.sh
```

#### 1.2 完整安装
```bash
# 下载并运行完整安装脚本
wget -O - https://raw.githubusercontent.com/kuku0799/5000/main/systemd_service.sh | bash

# 或者直接运行
chmod +x systemd_service.sh
./systemd_service.sh install
```

#### 1.3 服务管理
```bash
# 使用服务管理脚本
chmod +x service_manager.sh

# 安装服务
./service_manager.sh install

# 启动服务
./service_manager.sh start

# 查看状态
./service_manager.sh status

# 重启服务
./service_manager.sh restart

# 停止服务
./service_manager.sh stop

# 卸载服务
./service_manager.sh uninstall
```

### 方法2：使用init.d脚本（传统方法）

#### 2.1 创建init.d脚本
```bash
# 创建init.d脚本
cat > /etc/init.d/openclash-manager << 'EOF'
#!/bin/sh /etc/rc.common

START=99
STOP=10

start() {
    echo "启动OpenClash节点管理系统..."
    cd /root/OpenClashManage
    python3 web_editor.py > /dev/null 2>&1 &
    bash jk.sh > /dev/null 2>&1 &
    echo "服务已启动"
}

stop() {
    echo "停止OpenClash节点管理系统..."
    pkill -f "web_editor.py"
    pkill -f "jk.sh"
    echo "服务已停止"
}

restart() {
    stop
    sleep 2
    start
}
EOF

# 设置执行权限
chmod +x /etc/init.d/openclash-manager

# 启用开机自启动
/etc/init.d/openclash-manager enable
```

#### 2.2 管理服务
```bash
# 启动服务
/etc/init.d/openclash-manager start

# 停止服务
/etc/init.d/openclash-manager stop

# 重启服务
/etc/init.d/openclash-manager restart

# 查看状态
/etc/init.d/openclash-manager status
```

### 方法3：使用crontab（简单方法）

#### 3.1 创建启动脚本
```bash
# 创建启动脚本
cat > /root/start_openclash.sh << 'EOF'
#!/bin/bash
cd /root/OpenClashManage
python3 web_editor.py > /dev/null 2>&1 &
bash jk.sh > /dev/null 2>&1 &
EOF

# 设置执行权限
chmod +x /root/start_openclash.sh
```

#### 3.2 设置crontab
```bash
# 编辑crontab
crontab -e

# 添加以下行（开机时启动）
@reboot /root/start_openclash.sh

# 或者每分钟检查一次（如果服务停止则重启）
* * * * * /root/start_openclash.sh
```

### 方法4：使用rc.local（通用方法）

#### 4.1 编辑rc.local
```bash
# 编辑rc.local文件
nano /etc/rc.local

# 在exit 0之前添加以下内容
cd /root/OpenClashManage
python3 web_editor.py > /dev/null 2>&1 &
bash jk.sh > /dev/null 2>&1 &
```

## 🖥️ 不同系统的配置

### OpenWrt系统

#### 使用systemd（推荐）
```bash
# 下载OpenWrt专用脚本
wget https://raw.githubusercontent.com/kuku0799/5000/main/systemd_service.sh
chmod +x systemd_service.sh

# 安装服务（无需sudo）
./systemd_service.sh install
```

#### 使用procd（OpenWrt原生）
```bash
# 创建procd脚本
cat > /etc/init.d/openclash-manager << 'EOF'
#!/bin/sh /etc/rc.common

START=99
STOP=10

start_service() {
    procd_open_instance
    procd_set_param command /bin/bash
    procd_set_param args -c "cd /root/OpenClashManage && python3 web_editor.py & bash jk.sh"
    procd_set_param respawn
    procd_close_instance
}
EOF

chmod +x /etc/init.d/openclash-manager
/etc/init.d/openclash-manager enable
```

### Ubuntu/Debian系统

#### 使用systemd
```bash
# 下载并运行systemd脚本
wget https://raw.githubusercontent.com/kuku0799/5000/main/systemd_service.sh
chmod +x systemd_service.sh
sudo ./systemd_service.sh install
```

#### 使用upstart（旧版本）
```bash
# 创建upstart配置
sudo nano /etc/init/openclash-manager.conf

# 添加以下内容
description "OpenClash节点管理系统"
author "Your Name"

start on runlevel [2345]
stop on runlevel [016]

respawn
respawn limit 10 5

exec /bin/bash -c "cd /root/OpenClashManage && python3 web_editor.py & bash jk.sh"
```

### CentOS/RHEL系统

#### 使用systemd
```bash
# 下载并运行systemd脚本
wget https://raw.githubusercontent.com/kuku0799/5000/main/systemd_service.sh
chmod +x systemd_service.sh
sudo ./systemd_service.sh install
```

#### 使用chkconfig
```bash
# 创建SysV脚本
sudo nano /etc/init.d/openclash-manager

# 添加脚本内容（参考init.d部分）
sudo chmod +x /etc/init.d/openclash-manager
sudo chkconfig --add openclash-manager
sudo chkconfig openclash-manager on
```

## 🔍 验证自动启动

### 检查服务状态
```bash
# systemd服务
systemctl status openclash-manager-watchdog.service
systemctl status openclash-manager-web.service

# init.d服务
/etc/init.d/openclash-manager status

# 检查进程
ps aux | grep -E "(web_editor|jk.sh)"
```

### 测试重启
```bash
# 重启系统测试自动启动
reboot

# 重启后检查服务
systemctl status openclash-manager-watchdog.service
systemctl status openclash-manager-web.service
```

### 检查端口
```bash
# 检查Web编辑器端口
netstat -tlnp | grep :5000

# 或者使用ss命令
ss -tlnp | grep :5000
```

## 📊 服务管理命令

### systemd命令
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

## 🌐 访问Web界面

### 获取IP地址
```bash
# 获取本机IP
hostname -I
ip addr show

# 或者
ifconfig
```

### 访问Web编辑器
- 在浏览器中输入：`http://你的IP地址:5000`
- 例如：`http://192.168.1.100:5000`

## 📈 性能优化

### 资源监控
```bash
# 监控CPU和内存使用
top -p $(pgrep -f "web_editor\|jk.sh")

# 监控磁盘使用
df -h

# 监控网络连接
netstat -an | grep :5000
```

### 日志轮转
```bash
# 创建logrotate配置
cat > /etc/logrotate.d/openclash-manager << 'EOF'
/var/log/openclash-manager.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF
```

## 🔒 安全配置

### 防火墙设置
```bash
# 开放Web编辑器端口
ufw allow 5000

# 或者使用iptables
iptables -A INPUT -p tcp --dport 5000 -j ACCEPT
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
./service_manager.sh help

# 查看服务状态
./service_manager.sh status

# 查看详细日志
journalctl -u openclash-manager-watchdog.service -f
```

### 问题反馈
- 检查服务状态：`systemctl status openclash-manager-*.service`
- 查看错误日志：`journalctl -u openclash-manager-*.service -e`
- 重启服务：`systemctl restart openclash-manager-*.service`

---

**总结**：推荐使用systemd服务方法，它提供了最完整的功能和最好的管理体验。对于OpenWrt系统，可以直接运行 `./systemd_service.sh install` 来设置自动启动。 