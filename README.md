# 🌐 OpenClash 节点管理系统

一个完整的 OpenClash 节点管理解决方案，包含自动节点同步、Web 在线编辑器和开机自启动功能。

## 📋 功能特点

### 🔧 核心功能
- ✅ **自动节点同步**：监控节点文件变化，自动更新 OpenClash 配置
- ✅ **多协议支持**：支持 SS、Vmess、Vless、Trojan 协议
- ✅ **智能策略组**：自动将节点注入到所有策略组
- ✅ **配置验证**：自动验证配置有效性，失败时自动回滚
- ✅ **守护进程**：持续监控文件变化，确保实时同步

### 🌐 Web编辑器
- ✅ **在线编辑**：通过浏览器直接编辑节点配置文件
- ✅ **文件管理**：创建、编辑、删除文件
- ✅ **美观界面**：现代化UI设计，响应式布局
- ✅ **实时保存**：支持快捷键和状态提示

### 🔄 开机自启动
- ✅ **自动启动**：系统重启后自动启动服务
- ✅ **后台运行**：服务在后台持续运行，不占用终端
- ✅ **自动重启**：服务异常时自动重启
- ✅ **服务管理**：便捷的systemd服务管理
- ✅ **日志管理**：完整的日志记录和查看功能

## 🚀 快速部署

### 一键部署到 OpenWrt

```bash
# 方法1：使用 wget
wget -O - https://raw.githubusercontent.com/kuku0799/5000/main/install.sh | bash

# 方法2：使用 curl
curl -sSL https://raw.githubusercontent.com/kuku0799/5000/main/install.sh | bash
```

### 手动部署

```bash
# 1. 克隆仓库
git clone https://github.com/kuku0799/5000.git
cd 5000

# 2. 安装依赖
pip3 install -r requirements.txt

# 3. 启动 Web 编辑器
python3 web_editor.py

# 4. 启动守护进程
./jk.sh &
```

### 开机自启动设置

```bash
# 方法1：使用自动启动脚本（推荐）
chmod +x auto_start.sh
sudo ./auto_start.sh

# 方法2：使用服务管理脚本
chmod +x service_manager.sh
sudo ./service_manager.sh install

# 方法3：使用完整systemd安装脚本
chmod +x systemd_service.sh
sudo ./systemd_service.sh install
```

## 📁 项目结构

```
5000/
├── 核心系统
│   ├── jk.sh              # 守护进程脚本
│   ├── zr.py              # 主控制器
│   ├── jx.py              # 节点解析器
│   ├── zw.py              # 代理注入器
│   ├── zc.py              # 策略组注入器
│   └── log.py             # 日志管理器
├── Web编辑器
│   ├── web_editor.py      # Web服务器
│   ├── templates/
│   │   └── index.html     # 前端界面
│   ├── requirements.txt    # Python依赖
│   └── start_web_editor.sh # 启动脚本
├── 开机自启动
│   ├── auto_start.sh      # 快速自动启动脚本
│   ├── service_manager.sh # 服务管理脚本
│   ├── systemd_service.sh # 完整systemd安装脚本
│   └── README_AutoStart.md # 自启动说明文档
├── 配置文件
│   ├── wangluo/
│   │   ├── nodes.txt      # 节点配置文件
│   │   └── log.txt        # 系统日志
│   └── install.sh         # 一键安装脚本
└── 文档
    ├── README.md          # 主说明文档
    └── README_Web_Editor.md # Web编辑器说明
```

## 🎯 使用方法

### 1. 添加节点
1. 访问 Web 编辑器：`http://你的路由器IP:5000`
2. 编辑 `nodes.txt` 文件，添加节点链接
3. 保存文件，系统自动同步节点

### 2. 支持的节点格式
```
# SS 协议
ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@server.com:8388#节点名称

# Vmess 协议
vmess://eyJhZGQiOiJzZXJ2ZXIuY29tIiwicG9ydCI6NDQzLCJpZCI6IjEyMzQ1Njc4LTkwYWItMTFlYy1hYzE1LTAwMTYzYzFhYzE1NSIsImFpZCI6MCwidHlwZSI6Im5vbmUiLCJob3N0IjoiIiwicGF0aCI6IiIsInRscyI6InRscyJ9#节点名称

# Vless 协议
vless://uuid@server.com:443?security=tls#节点名称

# Trojan 协议
trojan://password@server.com:443#节点名称
```

## 🔧 服务管理

### 使用systemd服务（推荐）

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

### 手动启动（传统方式）

```bash
# 启动所有服务
cd /root/OpenClashManage && ./start_all.sh

# 停止所有服务
cd /root/OpenClashManage && ./stop_all.sh
```

## 🔄 工作流程

1. **添加节点** → 在 Web 编辑器中编辑 `nodes.txt`
2. **文件监控** → `jk.sh` 检测到文件变化
3. **节点解析** → `jx.py` 解析各种协议链接
4. **配置注入** → `zw.py` 注入节点到 proxies
5. **策略分组** → `zc.py` 注入节点到所有策略组
6. **配置验证** → 验证 OpenClash 配置有效性
7. **服务重启** → 重启 OpenClash 并应用新配置

## 🔒 安全特性

- ✅ **配置验证**：自动验证配置有效性
- ✅ **自动回滚**：配置错误时自动恢复
- ✅ **错误处理**：完善的错误处理和日志记录
- ✅ **权限控制**：安全的文件操作权限
- ✅ **服务隔离**：systemd服务安全配置

## 🐛 故障排除

### 常见问题

1. **pip3 magic number错误**
   ```bash
   # 快速修复pip3错误
   wget -O - https://raw.githubusercontent.com/kuku0799/5000/main/quick_fix_pip.sh | bash
   
   # 或者使用完整修复脚本
   wget -O - https://raw.githubusercontent.com/kuku0799/5000/main/fix_pip.sh | bash
   
   # 手动修复步骤
   sudo rm -f /usr/bin/pip3
   sudo opkg update
   sudo opkg install python3-pip --force-reinstall
   ```

2. **Web编辑器无法访问**
   ```bash
   # 检查端口是否被占用
   netstat -tlnp | grep 5000
   
   # 检查防火墙设置
   iptables -L
   
   # 检查服务状态
   sudo systemctl status openclash-manager-web.service
   ```

3. **节点同步失败**
   ```bash
   # 查看系统日志
   tail -f /root/OpenClashManage/wangluo/log.txt
   
   # 检查 OpenClash 状态
   /etc/init.d/openclash status
   
   # 查看服务日志
   sudo journalctl -u openclash-manager-watchdog.service -f
   ```

4. **开机自启动不工作**
   ```bash
   # 检查服务状态
   sudo systemctl status openclash-manager.service
   
   # 检查服务是否启用
   sudo systemctl is-enabled openclash-manager.service
   
   # 手动启用服务
   sudo systemctl enable openclash-manager.service
   ```

5. **配置文件错误**
   ```bash
   # 验证配置文件
   /etc/init.d/openclash verify_config /etc/openclash/config.yaml
   ```

## 📊 监控和维护

### 服务状态检查

```bash
# 查看所有相关服务状态
sudo systemctl status openclash-manager*

# 检查进程
ps aux | grep -E "(jk.sh|web_editor.py)"

# 检查端口监听
netstat -tlnp | grep :5000
```

### 日志管理

```bash
# 查看主服务日志
sudo journalctl -u openclash-manager.service -f

# 查看守护进程日志
sudo journalctl -u openclash-manager-watchdog.service -f

# 查看Web编辑器日志
sudo journalctl -u openclash-manager-web.service -f
```

## 📞 技术支持

- 📧 问题反馈：提交 GitHub Issue
- 📖 详细文档：查看 `README_Web_Editor.md` 和 `README_AutoStart.md`
- 🔧 配置帮助：查看代码注释

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🤝 贡献

欢迎提交 Pull Request 来改进这个项目！

---

**注意**：请确保在 OpenWrt 系统上使用，并具有适当的权限。 