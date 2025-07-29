# Clash 管理面板

一个基于 FastAPI + Vue.js 的现代化 Clash 管理面板，提供直观的 Web 界面来管理 OpenClash 配置。

## 功能特性

### 🎯 **核心功能**
- 📊 实时状态监控
- 🖥️ 节点管理和测试
- ⚙️ 策略组配置
- 📝 配置文件编辑
- 📋 日志查看
- 🔄 服务重启

### 🎨 **界面特性**
- 现代化响应式设计
- 实时数据更新
- 直观的操作界面
- 移动端适配

### 🛡️ **安全特性**
- 配置文件自动备份
- 错误处理和恢复
- 权限验证

## 技术栈

### 后端
- **FastAPI** - 高性能 Python Web 框架
- **Uvicorn** - ASGI 服务器
- **PyYAML** - YAML 配置文件处理
- **Pydantic** - 数据验证

### 前端
- **Vue.js 3** - 渐进式 JavaScript 框架
- **Bootstrap 5** - CSS 框架
- **Axios** - HTTP 客户端
- **Bootstrap Icons** - 图标库

## 快速安装

### 方式一：一键安装

```bash
# 下载安装脚本
wget -O install.sh https://raw.githubusercontent.com/你的用户名/clash-panel/main/install.sh

# 设置执行权限
chmod +x install.sh

# 运行安装
./install.sh
```

### 方式二：Docker 部署

```bash
# 克隆仓库
git clone https://github.com/你的用户名/clash-panel.git
cd clash-panel

# 构建并启动
docker-compose up -d
```

### 方式三：手动安装

```bash
# 1. 安装 Python 依赖
pip3 install fastapi uvicorn pyyaml python-multipart aiofiles

# 2. 复制文件
cp -r backend/ /opt/clash-panel/
cp -r frontend/ /opt/clash-panel/

# 3. 启动服务
cd /opt/clash-panel
python3 backend/main.py
```

## 使用方法

### 访问界面

安装完成后，在浏览器中访问：
```
http://你的路由器IP:8000
```

### 主要功能

#### 1. 仪表盘
- 查看 Clash 服务状态
- 监控内存和 CPU 使用
- 查看节点和策略组统计
- 快速重启服务

#### 2. 节点管理
- 查看所有节点列表
- 测试节点延迟
- 批量测试所有节点
- 节点状态监控

#### 3. 策略组
- 查看策略组配置
- 监控策略组状态
- 查看节点分配

#### 4. 配置管理
- 在线编辑配置文件
- 保存配置更改
- 配置备份和恢复

#### 5. 日志查看
- 实时查看系统日志
- 日志过滤和搜索
- 错误诊断

## API 接口

### 状态管理
```http
GET /api/status          # 获取服务状态
POST /api/restart        # 重启服务
```

### 节点管理
```http
GET /api/nodes           # 获取所有节点
GET /api/node/{name}/test # 测试节点延迟
```

### 配置管理
```http
GET /api/config          # 获取配置
POST /api/config         # 保存配置
GET /api/groups          # 获取策略组
```

### 日志管理
```http
GET /api/logs?lines=100  # 获取日志
```

## 项目结构

```
clash-panel/
├── backend/
│   └── main.py          # FastAPI 应用
├── frontend/
│   ├── index.html       # 主页面
│   └── app.js           # Vue.js 应用
├── static/              # 静态文件
├── requirements.txt     # Python 依赖
├── Dockerfile          # Docker 配置
├── docker-compose.yml  # Docker Compose
├── install.sh          # 安装脚本
└── README.md           # 说明文档
```

## 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `CONFIG_PATH` | `/etc/openclash/config.yaml` | Clash 配置文件路径 |
| `CLASH_SERVICE` | `openclash` | Clash 服务名称 |

### 端口配置

默认端口：`8000`

可以通过修改 `main.py` 中的 `uvicorn.run()` 参数来更改端口。

## 故障排除

### 常见问题

#### 1. 服务无法启动
```bash
# 检查 Python 依赖
pip3 list | grep fastapi

# 检查端口占用
netstat -tlnp | grep 8000

# 查看错误日志
tail -f /var/log/clash-panel.log
```

#### 2. 无法访问界面
```bash
# 检查防火墙
iptables -L | grep 8000

# 检查服务状态
/etc/init.d/clash-panel status

# 手动启动服务
python3 /opt/clash-panel/backend/main.py
```

#### 3. 配置文件读取失败
```bash
# 检查文件权限
ls -la /etc/openclash/config.yaml

# 检查文件内容
cat /etc/openclash/config.yaml
```

## 开发指南

### 本地开发

```bash
# 1. 克隆仓库
git clone https://github.com/你的用户名/clash-panel.git
cd clash-panel

# 2. 安装依赖
pip3 install -r requirements.txt

# 3. 启动开发服务器
python3 backend/main.py
```

### 添加新功能

1. **后端 API**：在 `backend/main.py` 中添加新的路由
2. **前端界面**：在 `frontend/app.js` 中添加新的方法
3. **样式调整**：修改 `frontend/index.html` 中的 CSS

## 贡献指南

欢迎提交 Issue 和 Pull Request！

### 开发规范

- 使用 Python 类型注解
- 遵循 PEP 8 代码规范
- 添加适当的错误处理
- 编写单元测试

## 许可证

MIT License

## 更新日志

### v1.0.0
- 初始版本发布
- 基础功能实现
- 现代化界面设计
- Docker 支持 