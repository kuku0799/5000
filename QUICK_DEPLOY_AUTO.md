# 🚀 OpenClash节点管理系统 - 快速部署指南（含开机自启动）

## 📋 快速部署步骤

### 方法一：一键安装（推荐）

```bash
# 一键安装，自动包含开机自启动功能
wget -O - https://raw.githubusercontent.com/kuku0799/5000/main/install.sh | bash
```

安装完成后，系统会自动：
- ✅ 下载所有必要文件
- ✅ 安装Python依赖
- ✅ 设置开机自启动
- ✅ 启动服务

### 方法二：手动安装

```bash
# 1. 克隆仓库
git clone https://github.com/kuku0799/5000.git
cd 5000

# 2. 设置开机自启动
chmod +x auto_start.sh
sudo ./auto_start.sh

# 3. 验证安装
sudo systemctl status openclash-manager.service
```

### 方法三：仅安装服务管理

```bash
# 1. 下载服务管理脚本
wget https://raw.githubusercontent.com/kuku0799/5000/main/service_manager.sh
chmod +x service_manager.sh

# 2. 安装服务
sudo ./service_manager.sh install

# 3. 查看状态
sudo ./service_manager.sh status
```

## 🔧 服务管理命令

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

# 查看状态
sudo ./service_manager.sh status

# 查看日志
sudo ./service_manager.sh logs

# 重启服务
sudo ./service_manager.sh restart

# 卸载服务
sudo ./service_manager.sh uninstall
```

## 🌐 访问地址

安装完成后，通过以下地址访问Web编辑器：

```
http://你的路由器IP:5000
```

## 📊 验证安装

### 检查服务状态

```bash
# 检查主服务
sudo systemctl status openclash-manager.service

# 检查子服务
sudo systemctl status openclash-manager-watchdog.service
sudo systemctl status openclash-manager-web.service
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

#### 3. 开机自启动不工作

```bash
# 检查服务是否启用
sudo systemctl is-enabled openclash-manager.service

# 手动启用服务
sudo systemctl enable openclash-manager.service

# 检查启动日志
sudo journalctl -u openclash-manager.service --since "boot"
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

## ⚡ 快速命令参考

```bash
# 一键安装
wget -O - https://raw.githubusercontent.com/kuku0799/5000/main/install.sh | bash

# 快速启动
sudo systemctl start openclash-manager.service

# 快速停止
sudo systemctl stop openclash-manager.service

# 快速重启
sudo systemctl restart openclash-manager.service

# 查看状态
sudo systemctl status openclash-manager.service

# 查看日志
sudo journalctl -u openclash-manager.service -f

# 访问Web界面
# 浏览器打开: http://你的路由器IP:5000
```

---

**注意**：
- 确保在OpenWrt系统上使用
- 需要root权限运行
- 建议在安装前备份现有配置
- 系统重启后服务会自动启动 