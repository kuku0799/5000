# 🌐 Wangluo Web编辑器

一个简单的在线文本编辑器，专门用于编辑 OpenClash 节点配置文件。

## 📋 功能特点

- ✅ **在线编辑**：通过浏览器直接编辑 `wangluo` 目录下的文件
- ✅ **文件管理**：创建、编辑、删除文件
- ✅ **实时保存**：支持文件保存和状态提示
- ✅ **响应式设计**：支持桌面和移动设备访问
- ✅ **美观界面**：现代化的UI设计，操作简单直观

## 🚀 快速开始

### 1. 安装依赖

```bash
# 安装Python依赖
pip3 install -r requirements.txt
```

### 2. 启动服务

```bash
# 方法1：使用启动脚本
./start_web_editor.sh

# 方法2：直接运行Python
python3 web_editor.py
```

### 3. 访问界面

打开浏览器访问：`http://你的路由器IP:5000`

例如：`http://192.168.1.1:5000`

## 📁 文件结构

```
5000/
├── web_editor.py          # Web服务器主程序
├── templates/
│   └── index.html         # 前端界面模板
├── requirements.txt        # Python依赖
├── start_web_editor.sh    # 启动脚本
└── README_Web_Editor.md   # 说明文档
```

## 🎯 使用方法

### 1. 编辑现有文件
1. 在左侧文件列表中点击要编辑的文件
2. 在右侧编辑器中修改内容
3. 点击"保存"按钮或使用快捷键 `Ctrl+S`

### 2. 创建新文件
1. 点击左侧的"新建文件"按钮
2. 输入文件名（例如：`nodes.txt`）
3. 点击"创建"按钮
4. 编辑文件内容并保存

### 3. 删除文件
1. 选择要删除的文件
2. 点击"删除"按钮
3. 确认删除操作

## 🔧 配置说明

### 修改文件目录
编辑 `web_editor.py` 文件中的 `WANGLUO_DIR` 变量：

```python
WANGLUO_DIR = "/root/OpenClashManage/wangluo"  # 修改为你的目录
```

### 修改端口
编辑 `web_editor.py` 文件末尾的端口设置：

```python
app.run(host='0.0.0.0', port=5000, debug=False)  # 修改端口号
```

## 📱 支持的协议

编辑器支持编辑各种代理协议链接：

- **SS协议**：`ss://...`
- **Vmess协议**：`vmess://...`
- **Vless协议**：`vless://...`
- **Trojan协议**：`trojan://...`

## 🔒 安全注意事项

1. **访问控制**：默认没有用户认证，建议在内网使用
2. **文件权限**：确保程序有读写 `wangluo` 目录的权限
3. **网络安全**：如需外网访问，请配置防火墙规则

## 🐛 故障排除

### 1. 无法启动服务
```bash
# 检查Python3是否安装
python3 --version

# 检查Flask是否安装
python3 -c "import flask"
```

### 2. 无法访问网页
```bash
# 检查端口是否被占用
netstat -tlnp | grep 5000

# 检查防火墙设置
iptables -L
```

### 3. 文件保存失败
```bash
# 检查目录权限
ls -la /root/OpenClashManage/wangluo

# 检查磁盘空间
df -h
```

## 📝 日志文件

Web编辑器的日志文件位置：`/root/OpenClashManage/wangluo/web_editor.log`

## 🔄 与现有系统集成

这个Web编辑器与现有的OpenClash管理系统完全兼容：

1. **文件同步**：编辑的文件会立即被 `jk.sh` 监控到
2. **自动处理**：文件变化会触发 `zr.py` 进行节点同步
3. **日志记录**：所有操作都会记录到系统日志中

## 🎨 界面预览

- **现代化设计**：渐变背景、毛玻璃效果
- **响应式布局**：适配各种屏幕尺寸
- **直观操作**：文件列表、编辑器、状态栏
- **实时反馈**：操作成功/失败提示

## 📞 技术支持

如有问题，请检查：
1. 日志文件：`/root/OpenClashManage/wangluo/web_editor.log`
2. 系统日志：`logread | grep web_editor`
3. 网络连接：`ping 路由器IP`

---

**注意**：这是一个轻量级的Web编辑器，专注于文件编辑功能。如需更多功能，请参考完整的管理界面设计方案。 