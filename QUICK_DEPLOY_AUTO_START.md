# 🚀 OpenClash节点管理系统 - 快速开机自启动部署指南

## 📋 概述

本指南将帮助您快速为OpenClash节点管理系统设置开机自启动，支持多种系统并自动检测最佳部署方式。

## 🎯 一键部署

### 方法1：使用完整部署脚本（推荐）

```bash
# 下载并运行部署脚本
wget -O - https://raw.githubusercontent.com/kuku0799/5000/main/deploy_auto_start.sh | bash

# 或者直接运行
chmod +x deploy_auto_start.sh
./deploy_auto_start.sh deploy
```

### 方法2：使用系统专用脚本

#### OpenWrt系统
```bash
# 传统OpenWrt（无systemd）
chmod +x openwrt_initd_setup.sh
./openwrt_initd_setup.sh install

# 现代OpenWrt（有systemd）
chmod +x openwrt_quick_setup.sh
./openwrt_quick_setup.sh install
```

#### 其他Linux系统
```bash
# 使用systemd服务
chmod +x systemd_service.sh
./systemd_service.sh install

# 使用服务管理脚本
chmod +x service_manager.sh
./service_manager.sh install
```

## 🔧 部署流程

### 1. 自动检测
- 检测系统类型（OpenWrt、Ubuntu、Debian、CentOS等）
- 检测init系统（systemd、init.d、rc.local）
- 检查必要文件
- 设置文件权限

### 2. 安装依赖
- 自动安装Python3和pip3
- 安装Flask等Python依赖
- 设置执行权限

### 3. 创建服务
- 根据系统类型选择最佳方法
- 创建systemd服务或init.d脚本
- 启用开机自启动
- 立即启动服务

### 4. 验证部署
- 检查进程状态
- 检查端口监听
- 显示访问信息

## 📊 支持的系统

| 系统类型 | 支持状态 | 推荐方法 |
|---------|---------|---------|
| OpenWrt (传统) | ✅ 完全支持 | init.d脚本 |
| OpenWrt (现代) | ✅ 完全支持 | systemd服务 |
| Ubuntu/Debian | ✅ 完全支持 | systemd服务 |
| CentOS/RHEL | ✅ 完全支持 | systemd服务 |
| 其他Linux | ✅ 基本支持 | rc.local |

## 🌐 访问Web界面

部署完成后，您可以通过以下方式访问：

1. **获取IP地址**
   ```bash
   hostname -I
   ```

2. **访问Web编辑器**
   - 在浏览器中输入：`http://你的IP地址:5000`
   - 例如：`http://192.168.1.100:5000`

## 📋 服务管理

### systemd系统
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
```

### init.d系统
```bash
# 启动服务
/etc/init.d/openclash-manager start

# 停止服务
/etc/init.d/openclash-manager stop

# 重启服务
/etc/init.d/openclash-manager restart

# 查看状态
/etc/init.d/openclash-manager status

# 启用开机自启动
/etc/init.d/openclash-manager enable
```

## 🔍 验证部署

### 检查进程
```bash
# 查看进程状态
ps aux | grep -E "(web_editor|jk.sh)"

# 查看端口
netstat -tlnp | grep :5000
```

### 检查服务状态
```bash
# systemd系统
systemctl status openclash-manager-*.service

# init.d系统
/etc/init.d/openclash-manager status
```

### 测试重启
```bash
# 重启系统测试自动启动
reboot

# 重启后检查服务
./deploy_auto_start.sh status
```

## 🔧 故障排除

### 常见问题

#### 1. 服务启动失败
```bash
# 检查依赖
python3 --version
pip3 --version

# 检查文件权限
ls -la jk.sh web_editor.py

# 检查端口占用
netstat -tlnp | grep :5000
```

#### 2. 开机不自动启动
```bash
# systemd系统
systemctl is-enabled openclash-manager-*.service

# init.d系统
ls -la /etc/rc.d/S*openclash-manager
```

#### 3. 权限问题
```bash
# 确保脚本有执行权限
chmod +x *.sh *.py

# 检查用户权限
whoami
```

#### 4. 端口冲突
```bash
# 检查端口占用
lsof -i :5000

# 修改端口（编辑web_editor.py）
nano web_editor.py
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

### 日志查看
```bash
# systemd系统
journalctl -u openclash-manager-watchdog.service -f
journalctl -u openclash-manager-web.service -f

# init.d系统
tail -f /var/log/messages
```

## 🔒 安全配置

### 防火墙设置
```bash
# Ubuntu/Debian
ufw allow 5000

# CentOS/RHEL
firewall-cmd --permanent --add-port=5000/tcp
firewall-cmd --reload

# OpenWrt
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
# 查看部署脚本帮助
./deploy_auto_start.sh help

# 查看服务状态
./deploy_auto_start.sh status

# 查看详细日志
journalctl -u openclash-manager-*.service -f
```

### 问题反馈
- 检查服务状态：`systemctl status openclash-manager-*.service`
- 查看错误日志：`journalctl -u openclash-manager-*.service -e`
- 重启服务：`systemctl restart openclash-manager-*.service`

## 🎯 快速命令参考

### 部署命令
```bash
# 一键部署
./deploy_auto_start.sh deploy

# 查看状态
./deploy_auto_start.sh status

# 系统专用部署
./openwrt_initd_setup.sh install    # OpenWrt传统
./openwrt_quick_setup.sh install    # OpenWrt现代
./systemd_service.sh install         # 其他Linux
```

### 管理命令
```bash
# 启动服务
systemctl start openclash-manager-*.service
/etc/init.d/openclash-manager start

# 停止服务
systemctl stop openclash-manager-*.service
/etc/init.d/openclash-manager stop

# 重启服务
systemctl restart openclash-manager-*.service
/etc/init.d/openclash-manager restart

# 查看状态
systemctl status openclash-manager-*.service
/etc/init.d/openclash-manager status
```

---

**总结**：使用 `./deploy_auto_start.sh deploy` 可以一键完成所有部署工作，脚本会自动检测系统类型并选择最佳部署方式。 