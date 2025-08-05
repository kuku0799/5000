# 🚀 一键部署指南

## 📱 快速部署到 OpenWrt

### 方法1：使用 wget（推荐）
```bash
wget -O - https://raw.githubusercontent.com/kuku0799/5000/main/install.sh | bash
```

### 方法2：使用 curl
```bash
curl -sSL https://raw.githubusercontent.com/kuku0799/5000/main/install.sh | bash
```

### 方法3：手动下载后执行
```bash
# 下载安装脚本
wget https://raw.githubusercontent.com/kuku0799/5000/main/install.sh

# 执行安装
bash install.sh
```

## 🎯 部署后使用

### 1. 启动服务
```bash
cd /root/OpenClashManage
./start_all.sh
```

### 2. 访问 Web 编辑器
打开浏览器访问：`http://你的路由器IP:5000`

### 3. 添加节点
1. 在 Web 编辑器中编辑 `nodes.txt` 文件
2. 添加你的节点链接
3. 保存文件，系统自动同步

## 📋 支持的节点格式

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

## 🔧 管理命令

### 启动所有服务
```bash
cd /root/OpenClashManage && ./start_all.sh
```

### 停止所有服务
```bash
cd /root/OpenClashManage && ./stop_all.sh
```

### 查看日志
```bash
tail -f /root/OpenClashManage/wangluo/log.txt
```

### 检查状态
```bash
# 检查 Web 编辑器
ps aux | grep web_editor.py

# 检查守护进程
ps aux | grep jk.sh

# 检查 OpenClash
/etc/init.d/openclash status
```

## 🐛 故障排除

### 如果安装失败
```bash
# 检查 Python3
python3 --version

# 手动安装依赖
pip3 install Flask==2.3.3 Werkzeug==2.3.7

# 重新运行安装
bash install.sh
```

### 如果 Web 编辑器无法访问
```bash
# 检查端口
netstat -tlnp | grep 5000

# 检查防火墙
iptables -L

# 重启 Web 编辑器
cd /root/OpenClashManage
pkill -f web_editor.py
python3 web_editor.py &
```

## 📞 技术支持

- **GitHub 仓库**：https://github.com/kuku0799/5000
- **问题反馈**：提交 GitHub Issue
- **详细文档**：查看 README.md

---

**注意**：请确保在 OpenWrt 系统上使用，并已安装 OpenClash 插件。 