# 🌐 OpenClash 节点管理系统

一个完整的 OpenClash 节点管理解决方案，包含自动节点同步和 Web 在线编辑器。

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

## 🚀 快速部署

### 一键部署到 OpenWrt

```bash
# 方法1：使用 wget
wget -O - https://raw.githubusercontent.com/你的用户名/你的仓库名/main/install.sh | bash

# 方法2：使用 curl
curl -sSL https://raw.githubusercontent.com/你的用户名/你的仓库名/main/install.sh | bash
```

### 手动部署

```bash
# 1. 克隆仓库
git clone https://github.com/你的用户名/你的仓库名.git
cd 你的仓库名

# 2. 安装依赖
pip3 install -r requirements.txt

# 3. 启动 Web 编辑器
python3 web_editor.py

# 4. 启动守护进程
./jk.sh &
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

## 🔧 配置说明

### 修改文件路径
编辑相关文件中的路径配置：
```bash
# 默认路径
/root/OpenClashManage/wangluo/
```

### 修改端口
编辑 `web_editor.py` 中的端口设置：
```python
app.run(host='0.0.0.0', port=5000, debug=False)
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

## 🐛 故障排除

### 常见问题

1. **Web编辑器无法访问**
   ```bash
   # 检查端口是否被占用
   netstat -tlnp | grep 5000
   
   # 检查防火墙设置
   iptables -L
   ```

2. **节点同步失败**
   ```bash
   # 查看系统日志
   tail -f /root/OpenClashManage/wangluo/log.txt
   
   # 检查 OpenClash 状态
   /etc/init.d/openclash status
   ```

3. **配置文件错误**
   ```bash
   # 验证配置文件
   /etc/init.d/openclash verify_config /etc/openclash/config.yaml
   ```

## 📞 技术支持

- 📧 问题反馈：提交 GitHub Issue
- 📖 详细文档：查看 `README_Web_Editor.md`
- 🔧 配置帮助：查看代码注释

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🤝 贡献

欢迎提交 Pull Request 来改进这个项目！

---

**注意**：请确保在 OpenWrt 系统上使用，并具有适当的权限。 