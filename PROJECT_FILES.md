# 📁 OpenClash节点管理系统 - 项目文件列表

## 🔧 核心系统文件

### 守护进程和监控
- `jk.sh` - 守护进程脚本
  - 监控节点文件变化
  - 自动触发同步操作
  - 防止多开机制
  - 完整的日志记录

### Python核心模块
- `zr.py` - 主控制器
  - 协调各个模块工作
  - 处理配置更新流程
  - 错误处理和回滚机制

- `jx.py` - 节点解析器
  - 解析各种协议链接
  - 支持SS、Vmess、Vless、Trojan
  - 节点信息提取和验证

- `zw.py` - 代理注入器
  - 将节点注入到proxies配置
  - 处理节点格式转换
  - 配置验证和优化

- `zc.py` - 策略组注入器
  - 将节点注入到所有策略组
  - 智能策略组管理
  - 配置同步和更新

- `log.py` - 日志管理器
  - 统一的日志记录
  - 日志格式化和输出
  - 错误追踪和调试

## 🌐 Web编辑器

### 服务器和界面
- `web_editor.py` - Web服务器
  - Flask Web应用
  - 文件管理API
  - 实时编辑功能
  - 安全文件操作

- `templates/index.html` - 前端界面
  - 现代化UI设计
  - 响应式布局
  - 实时保存功能
  - 文件管理界面

### 启动和配置
- `start_web_editor.sh` - Web编辑器启动脚本
  - 环境检查
  - 依赖安装
  - 服务启动
  - 状态显示

- `requirements.txt` - Python依赖
  - Flask框架
  - Werkzeug工具
  - 其他必要包

## 🔄 开机自启动

### 自动启动脚本
- `auto_start.sh` - 快速自动启动脚本
  - 简化版本，快速设置
  - 自动创建systemd服务
  - 自动启用开机自启动
  - 自动启动服务

- `service_manager.sh` - 服务管理脚本
  - 完整的服务管理工具
  - 安装、卸载、启动、停止、重启
  - 状态查看和日志管理
  - 系统状态检查

- `systemd_service.sh` - 完整systemd安装脚本
  - 功能完整的服务安装
  - 详细的安全配置
  - 完整的错误处理
  - 支持安装、卸载、状态查看

### 服务配置
- `README_AutoStart.md` - 开机自启动详细说明
  - 完整的使用说明
  - 故障排除指南
  - 安全配置说明
  - 监控和维护指南

## 📦 安装和部署

### 一键安装
- `install.sh` - 一键安装脚本
  - 系统环境检查
  - 自动下载文件
  - 依赖安装
  - 开机自启动设置
  - 服务启动和验证

### 快速部署
- `QUICK_DEPLOY.md` - 快速部署说明
  - 基本部署步骤
  - 配置说明
  - 使用指南

- `QUICK_DEPLOY_AUTO.md` - 快速部署指南（含开机自启动）
  - 快速部署步骤
  - 服务管理命令
  - 验证安装方法
  - 故障排除指南

## 📚 文档和说明

### 主要文档
- `README.md` - 主说明文档
  - 项目概述
  - 功能特点
  - 安装和使用方法
  - 故障排除

- `README_Web_Editor.md` - Web编辑器说明
  - Web编辑器功能
  - 界面说明
  - 使用方法
  - 配置选项

### 更新和总结
- `UPDATE_SUMMARY.md` - 更新总结
  - 更新概述
  - 新增功能
  - 技术特性
  - 兼容性说明

- `DEPLOYMENT_SUMMARY.md` - 部署总结
  - 部署流程
  - 配置要点
  - 常见问题

## 🛠️ 工具和脚本

### 测试和修复
- `test_links.py` - 链接测试工具
  - 节点链接验证
  - 协议支持测试
  - 连接性检查

- `fix_dependencies.sh` - 依赖修复脚本
  - Python依赖修复
  - 系统包安装
  - 环境配置

- `fix_pip.sh` - pip3修复脚本
  - 修复pip3 magic number错误
  - 重新安装pip3
  - 环境清理和恢复

- `quick_fix_pip.sh` - 快速pip3修复脚本
  - 快速修复pip3问题
  - 适用于紧急情况
  - 简化修复流程

### 开发和部署
- `git_commit.sh` - Git提交脚本
  - 自动提交更改
  - 标签管理
  - 远程推送
  - 状态检查

## 🔧 配置和日志

### 配置目录
- `wangluo/` - 配置目录
  - `nodes.txt` - 节点配置文件
  - `log.txt` - 系统日志文件

### 其他配置
- `LICENSE` - 许可证文件
- `.gitignore` - Git忽略文件

## 🚀 GitHub Actions

### 自动化工作流
- `.github/workflows/update-docs.yml` - 文档更新工作流
  - 自动验证脚本
  - 创建发布说明
  - 更新文档
  - 自动发布

## 📊 文件统计

### 按类型分类
- **Shell脚本**: 8个
  - 守护进程、启动脚本、服务管理、安装脚本等

- **Python文件**: 7个
  - 核心模块、Web服务器、测试工具等

- **HTML模板**: 1个
  - Web编辑器前端界面

- **Markdown文档**: 6个
  - 说明文档、部署指南、更新总结等

- **配置文件**: 3个
  - 依赖文件、许可证、Git配置等

### 按功能分类
- **核心系统**: 6个文件
- **Web编辑器**: 4个文件
- **开机自启动**: 4个文件
- **安装部署**: 3个文件
- **文档说明**: 6个文件
- **工具脚本**: 3个文件
- **配置日志**: 3个文件
- **自动化**: 1个文件

## 🔍 文件关系图

```
5000/
├── 核心系统 (6个文件)
│   ├── jk.sh (守护进程)
│   ├── zr.py (主控制器)
│   ├── jx.py (节点解析器)
│   ├── zw.py (代理注入器)
│   ├── zc.py (策略组注入器)
│   └── log.py (日志管理器)
├── Web编辑器 (4个文件)
│   ├── web_editor.py (服务器)
│   ├── templates/index.html (界面)
│   ├── start_web_editor.sh (启动脚本)
│   └── requirements.txt (依赖)
├── 开机自启动 (4个文件)
│   ├── auto_start.sh (快速启动)
│   ├── service_manager.sh (服务管理)
│   ├── systemd_service.sh (完整安装)
│   └── README_AutoStart.md (说明文档)
├── 安装部署 (3个文件)
│   ├── install.sh (一键安装)
│   ├── QUICK_DEPLOY.md (快速部署)
│   └── QUICK_DEPLOY_AUTO.md (自启动部署)
├── 文档说明 (6个文件)
│   ├── README.md (主文档)
│   ├── README_Web_Editor.md (Web编辑器说明)
│   ├── UPDATE_SUMMARY.md (更新总结)
│   ├── DEPLOYMENT_SUMMARY.md (部署总结)
│   ├── PROJECT_FILES.md (文件列表)
│   └── LICENSE (许可证)
├── 工具脚本 (3个文件)
│   ├── test_links.py (链接测试)
│   ├── fix_dependencies.sh (依赖修复)
│   └── git_commit.sh (Git提交)
├── 配置日志 (3个文件)
│   ├── wangluo/nodes.txt (节点配置)
│   ├── wangluo/log.txt (系统日志)
│   └── .gitignore (Git忽略)
└── 自动化 (1个文件)
    └── .github/workflows/update-docs.yml (GitHub Actions)
```

## 📋 使用建议

### 新用户
1. 使用 `install.sh` 一键安装
2. 阅读 `README.md` 了解基本功能
3. 访问Web编辑器管理节点
4. 使用 `service_manager.sh` 管理服务

### 高级用户
1. 使用 `auto_start.sh` 设置开机自启动
2. 使用 `service_manager.sh` 进行高级管理
3. 查看 `README_AutoStart.md` 了解详细配置
4. 使用 `git_commit.sh` 管理代码版本

### 开发者
1. 查看 `UPDATE_SUMMARY.md` 了解最新更新
2. 使用 `test_links.py` 测试节点链接
3. 使用 `fix_dependencies.sh` 修复环境问题
4. 使用 `git_commit.sh` 提交代码更改

---

**总计**: 30个文件，涵盖完整的OpenClash节点管理解决方案 