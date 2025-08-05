# 🔄 OpenClash节点管理系统 - 开机自启动和后台运行

本文档介绍如何为OpenClash节点管理系统设置开机自启动和后台运行功能。

## 📋 功能概述

### ✅ 已实现功能
- **开机自启动**：系统重启后自动启动服务
- **后台运行**：服务在后台持续运行，不占用终端
- **自动重启**：服务异常时自动重启
- **日志管理**：完整的日志记录和查看功能
- **服务管理**：便捷的服务启动、停止、重启命令

## 🚀 快速安装

### 方法一：使用自动启动脚本（推荐）

```bash
# 1. 给脚本执行权限
chmod +x auto_start.sh

# 2. 运行安装脚本
sudo ./auto_start.sh
```

### 方法二：使用完整服务管理脚本

```bash
# 1. 给脚本执行权限
chmod +x service_manager.sh

# 2. 安装服务
sudo ./service_manager.sh install

# 3. 查看服务状态
sudo ./service_manager.sh status
```

### 方法三：使用systemd服务安装脚本

```bash
# 1. 给脚本执行权限
chmod +x systemd_service.sh

# 2. 安装服务
sudo ./systemd_service.sh install

# 3. 查看状态
sudo ./systemd_service.sh status
```

## 🔧 服务管理

### 基本命令

```bash
# 启动服务
sudo systemctl start openclash-manager.service

# 停止服务
sudo systemctl stop openclash-manager.service

# 重启服务
sudo systemctl restart openclash-manager.service

# 查看状态
sudo systemctl status openclash-manager.service

# 查看日志
sudo journalctl -u openclash-manager.service -f
```

### 使用服务管理脚本

```bash
# 查看帮助
./service_manager.sh help

# 安装服务
sudo ./service_manager.sh install

# 查看状态
sudo ./service_manager.sh status

# 查看日志
sudo ./service_manager.sh logs

# 重启服务
sudo ./service_manager.sh restart

# 卸载服务
sudo ./service_manager.sh uninstall
```

## 📁 服务文件结构

安装后会在系统中创建以下服务文件：

```
/etc/systemd/system/
├── openclash-manager.service          # 主服务（组合服务）
├── openclash-manager-watchdog.service # 守护进程服务
└── openclash-manager-web.service      # Web编辑器服务
```

### 服务说明

#### 1. 主服务 (openclash-manager.service)
- **类型**：oneshot
- **功能**：同时启动守护进程和Web编辑器
- **依赖**：网络服务

#### 2. 守护进程服务 (openclash-manager-watchdog.service)
- **类型**：simple
- **功能**：监控节点文件变化，自动同步配置
- **重启策略**：always（异常时自动重启）
- **工作目录**：/root/OpenClashManage

#### 3. Web编辑器服务 (openclash-manager-web.service)
- **类型**：simple
- **功能**：提供Web界面进行节点管理
- **端口**：5000
- **环境**：production模式
- **重启策略**：always（异常时自动重启）

## 🔍 状态检查

### 检查服务状态

```bash
# 查看所有相关服务状态
sudo systemctl status openclash-manager*
```

### 检查进程

```bash
# 检查守护进程
ps aux | grep jk.sh

# 检查Web编辑器
ps aux | grep web_editor.py

# 检查端口监听
netstat -tlnp | grep :5000
```

### 检查日志

```bash
# 查看主服务日志
sudo journalctl -u openclash-manager.service -f

# 查看守护进程日志
sudo journalctl -u openclash-manager-watchdog.service -f

# 查看Web编辑器日志
sudo journalctl -u openclash-manager-web.service -f
```

## 🛠️ 故障排除

### 常见问题

#### 1. 服务启动失败

```bash
# 检查服务状态
sudo systemctl status openclash-manager.service

# 查看详细日志
sudo journalctl -u openclash-manager.service -n 50

# 检查文件权限
ls -la /root/OpenClashManage/jk.sh
ls -la /root/OpenClashManage/web_editor.py
```

#### 2. Web编辑器无法访问

```bash
# 检查端口是否被占用
sudo netstat -tlnp | grep :5000

# 检查防火墙设置
sudo iptables -L

# 检查服务状态
sudo systemctl status openclash-manager-web.service
```

#### 3. 守护进程不工作

```bash
# 检查进程
ps aux | grep jk.sh

# 查看日志
sudo journalctl -u openclash-manager-watchdog.service -f

# 检查文件是否存在
ls -la /root/OpenClashManage/wangluo/nodes.txt
```

### 手动启动测试

```bash
# 测试守护进程
cd /root/OpenClashManage
sudo ./jk.sh

# 测试Web编辑器
cd /root/OpenClashManage
sudo python3 web_editor.py
```

## 🔒 安全配置

### 服务安全设置

所有服务都配置了以下安全选项：

- **NoNewPrivileges=true**：防止获取新权限
- **PrivateTmp=true**：使用私有临时目录
- **ProtectSystem=strict**：保护系统文件
- **ProtectHome=true**：保护用户目录
- **ReadWritePaths**：限制可写路径

### 权限管理

```bash
# 设置正确的文件权限
sudo chmod 755 /root/OpenClashManage
sudo chmod +x /root/OpenClashManage/jk.sh
sudo chmod +x /root/OpenClashManage/start_web_editor.sh

# 确保目录存在
sudo mkdir -p /root/OpenClashManage/wangluo
sudo mkdir -p /root/OpenClashManage/templates
```

## 📊 监控和维护

### 系统监控

```bash
# 查看服务运行时间
sudo systemctl show openclash-manager.service --property=ActiveEnterTimestamp

# 查看重启次数
sudo systemctl show openclash-manager.service --property=NRestarts

# 查看资源使用
ps aux | grep -E "(jk.sh|web_editor.py)"
```

### 日志轮转

系统会自动管理日志，但也可以手动清理：

```bash
# 清理旧日志
sudo journalctl --vacuum-time=7d

# 查看日志大小
sudo journalctl --disk-usage
```

## 🔄 更新和维护

### 更新服务

```bash
# 停止服务
sudo systemctl stop openclash-manager.service

# 更新代码文件
# ... 更新相关文件 ...

# 重新启动服务
sudo systemctl start openclash-manager.service
```

### 重新安装

```bash
# 卸载旧服务
sudo ./service_manager.sh uninstall

# 重新安装
sudo ./service_manager.sh install
```

## 📞 技术支持

### 获取帮助

```bash
# 查看服务管理脚本帮助
./service_manager.sh help

# 检查系统状态
sudo ./service_manager.sh check

# 查看服务状态
sudo ./service_manager.sh status
```

### 日志分析

```bash
# 查看最近的错误
sudo journalctl -u openclash-manager* --since "1 hour ago" | grep -i error

# 查看启动日志
sudo journalctl -u openclash-manager* --since "today" | grep -i "start\|stop"
```

---

**注意**：
- 所有脚本都需要root权限运行
- 确保在OpenWrt系统上使用
- 服务安装后会自动启用开机自启动
- 建议定期检查服务状态和日志 