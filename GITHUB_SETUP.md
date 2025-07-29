<<<<<<< HEAD
# GitHub 上传指南

## 准备工作

### 1. 创建 GitHub 仓库

1. 访问 [GitHub](https://github.com)
2. 点击 "New repository"
3. 仓库名称：`OpenClashManage`
4. 描述：`OpenWrt OpenClash 节点自动同步管理系统`
5. 选择 "Public"
6. 不要初始化 README（我们已经有文件了）
7. 点击 "Create repository"

### 2. 本地 Git 初始化

```bash
# 初始化 Git 仓库
git init

# 添加远程仓库
git remote add origin https://github.com/你的用户名/OpenClashManage.git

# 添加所有文件
git add .

# 提交更改
git commit -m "Initial commit: OpenClash 管理系统"

# 推送到 GitHub
git push -u origin main
```

## 文件结构

```
OpenClashManage/
├── .github/
│   └── workflows/
│       └── test.yml          # GitHub Actions 测试
├── jk.sh                     # 守护进程脚本
├── jx.py                     # 节点解析器
├── zr.py                     # 主控制器
├── zw.py                     # 代理注入器
├── zc.py                     # 策略组注入器
├── log.py                    # 日志模块
├── install.sh                # 一键安装脚本
├── uninstall.sh              # 一键卸载脚本
├── README.md                 # 项目说明文档
├── LICENSE                   # MIT 许可证
├── .gitignore               # Git 忽略文件
└── GITHUB_SETUP.md          # 本文件
```

## 更新 README.md

记得将 README.md 中的链接替换为你的实际 GitHub 用户名：

```markdown
# 将以下链接中的 "你的用户名" 替换为你的实际 GitHub 用户名

wget -O install.sh https://raw.githubusercontent.com/你的用户名/OpenClashManage/main/install.sh

git clone https://github.com/你的用户名/OpenClashManage.git
```

## 发布 Release

### 1. 创建 Release

1. 在 GitHub 仓库页面点击 "Releases"
2. 点击 "Create a new release"
3. 标签：`v1.0.0`
4. 标题：`OpenClash 管理系统 v1.0.0`
5. 描述：

```markdown
## 🎉 首次发布

### 功能特性
- ✅ 支持 4 种代理协议（Shadowsocks、VMess、VLESS、Trojan）
- ✅ 自动节点同步和配置更新
- ✅ 智能策略组识别和注入
- ✅ 一键安装和卸载脚本
- ✅ 完整的错误处理和日志记录

### 快速安装
```bash
wget -O install.sh https://raw.githubusercontent.com/你的用户名/OpenClashManage/main/install.sh
chmod +x install.sh
./install.sh
```

### 系统要求
- OpenWrt 系统
- Python 3.6+
- 网络连接
```

### 2. 上传文件

在 Release 页面可以上传：
- `install.sh` - 安装脚本
- `uninstall.sh` - 卸载脚本
- 整个项目 ZIP 文件

## 持续集成

GitHub Actions 会自动：
- ✅ 测试 Python 脚本语法
- ✅ 验证 Shell 脚本语法
- ✅ 检查文件权限
- ✅ 运行基本功能测试

## 维护更新

### 推送更新

```bash
# 修改文件后
git add .
git commit -m "更新说明"
git push origin main
```

### 创建新版本

```bash
# 创建新标签
git tag v1.0.1
git push origin v1.0.1

# 然后在 GitHub 创建对应的 Release
```

## 用户安装方式

用户可以通过以下方式安装：

### 1. 直接下载安装脚本
```bash
wget -O install.sh https://raw.githubusercontent.com/你的用户名/OpenClashManage/main/install.sh
chmod +x install.sh
./install.sh
```

### 2. 克隆仓库安装
```bash
git clone https://github.com/你的用户名/OpenClashManage.git
cd OpenClashManage
chmod +x install.sh
./install.sh
```

### 3. 从 Release 下载
```bash
# 下载 Release 中的安装脚本
wget https://github.com/你的用户名/OpenClashManage/releases/download/v1.0.0/install.sh
chmod +x install.sh
./install.sh
```

## 注意事项

1. **替换用户名**：记得将所有文件中的 "你的用户名" 替换为实际的 GitHub 用户名
2. **测试安装**：在发布前测试安装脚本是否正常工作
3. **文档更新**：保持 README.md 的及时更新
4. **版本管理**：使用语义化版本号管理发布
=======
# GitHub 上传指南

## 准备工作

### 1. 创建 GitHub 仓库

1. 访问 [GitHub](https://github.com)
2. 点击 "New repository"
3. 仓库名称：`OpenClashManage`
4. 描述：`OpenWrt OpenClash 节点自动同步管理系统`
5. 选择 "Public"
6. 不要初始化 README（我们已经有文件了）
7. 点击 "Create repository"

### 2. 本地 Git 初始化

```bash
# 初始化 Git 仓库
git init

# 添加远程仓库
git remote add origin https://github.com/你的用户名/OpenClashManage.git

# 添加所有文件
git add .

# 提交更改
git commit -m "Initial commit: OpenClash 管理系统"

# 推送到 GitHub
git push -u origin main
```

## 文件结构

```
OpenClashManage/
├── .github/
│   └── workflows/
│       └── test.yml          # GitHub Actions 测试
├── jk.sh                     # 守护进程脚本
├── jx.py                     # 节点解析器
├── zr.py                     # 主控制器
├── zw.py                     # 代理注入器
├── zc.py                     # 策略组注入器
├── log.py                    # 日志模块
├── install.sh                # 一键安装脚本
├── uninstall.sh              # 一键卸载脚本
├── README.md                 # 项目说明文档
├── LICENSE                   # MIT 许可证
├── .gitignore               # Git 忽略文件
└── GITHUB_SETUP.md          # 本文件
```

## 更新 README.md

记得将 README.md 中的链接替换为你的实际 GitHub 用户名：

```markdown
# 将以下链接中的 "你的用户名" 替换为你的实际 GitHub 用户名

wget -O install.sh https://raw.githubusercontent.com/你的用户名/OpenClashManage/main/install.sh

git clone https://github.com/你的用户名/OpenClashManage.git
```

## 发布 Release

### 1. 创建 Release

1. 在 GitHub 仓库页面点击 "Releases"
2. 点击 "Create a new release"
3. 标签：`v1.0.0`
4. 标题：`OpenClash 管理系统 v1.0.0`
5. 描述：

```markdown
## 🎉 首次发布

### 功能特性
- ✅ 支持 4 种代理协议（Shadowsocks、VMess、VLESS、Trojan）
- ✅ 自动节点同步和配置更新
- ✅ 智能策略组识别和注入
- ✅ 一键安装和卸载脚本
- ✅ 完整的错误处理和日志记录

### 快速安装
```bash
wget -O install.sh https://raw.githubusercontent.com/你的用户名/OpenClashManage/main/install.sh
chmod +x install.sh
./install.sh
```

### 系统要求
- OpenWrt 系统
- Python 3.6+
- 网络连接
```

### 2. 上传文件

在 Release 页面可以上传：
- `install.sh` - 安装脚本
- `uninstall.sh` - 卸载脚本
- 整个项目 ZIP 文件

## 持续集成

GitHub Actions 会自动：
- ✅ 测试 Python 脚本语法
- ✅ 验证 Shell 脚本语法
- ✅ 检查文件权限
- ✅ 运行基本功能测试

## 维护更新

### 推送更新

```bash
# 修改文件后
git add .
git commit -m "更新说明"
git push origin main
```

### 创建新版本

```bash
# 创建新标签
git tag v1.0.1
git push origin v1.0.1

# 然后在 GitHub 创建对应的 Release
```

## 用户安装方式

用户可以通过以下方式安装：

### 1. 直接下载安装脚本
```bash
wget -O install.sh https://raw.githubusercontent.com/你的用户名/OpenClashManage/main/install.sh
chmod +x install.sh
./install.sh
```

### 2. 克隆仓库安装
```bash
git clone https://github.com/你的用户名/OpenClashManage.git
cd OpenClashManage
chmod +x install.sh
./install.sh
```

### 3. 从 Release 下载
```bash
# 下载 Release 中的安装脚本
wget https://github.com/你的用户名/OpenClashManage/releases/download/v1.0.0/install.sh
chmod +x install.sh
./install.sh
```

## 注意事项

1. **替换用户名**：记得将所有文件中的 "你的用户名" 替换为实际的 GitHub 用户名
2. **测试安装**：在发布前测试安装脚本是否正常工作
3. **文档更新**：保持 README.md 的及时更新
4. **版本管理**：使用语义化版本号管理发布
>>>>>>> fe207d4f91869b46530d24008bed31cbb4a6f158
5. **问题反馈**：及时响应用户的 Issue 和 Pull Request 