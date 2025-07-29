# OpenClash 管理系统

一个用于 OpenWrt 的 OpenClash 节点自动同步管理系统，支持多种代理协议，提供自动化的节点管理和配置更新。

## 功能特性

### 🔄 **自动同步**
- 监控节点文件变化，自动触发同步
- 支持多种代理协议：Shadowsocks、VMess、VLESS、Trojan
- 智能去重和节点验证

### 🛡️ **安全可靠**
- 配置验证和自动备份
- 错误恢复和回滚机制
- 进程锁防止重复执行

### 📊 **状态监控**
- 实时日志记录
- 节点数量统计
- 同步状态反馈

### 🎯 **智能管理**
- 自动识别策略组
- 智能节点名称处理
- 配置文件语法验证

## 系统架构

```
jk.sh (守护进程)
    ↓
zr.py (主控制器)
    ↓
jx.py (节点解析) → zw.py (代理注入) → zc.py (策略组注入)
    ↓
生成 OpenClash 配置文件
```

## 快速安装

### 一键安装

#### 方式一：从 GitHub 直接安装

```bash
# 下载并运行安装脚本
wget -O install.sh https://raw.githubusercontent.com/你的用户名/OpenClashManage/main/install.sh
chmod +x install.sh
./install.sh
```

#### 方式二：克隆仓库后安装

```bash
# 克隆仓库
git clone https://github.com/你的用户名/OpenClashManage.git
cd OpenClashManage

# 运行安装脚本
chmod +x install.sh
./install.sh
```

### 手动安装

1. **上传文件到路由器**
```bash
scp *.py *.sh root@192.168.1.1:/root/
```

2. **设置权限**
```bash
chmod +x *.sh *.py
```

3. **创建目录**
```bash
mkdir -p /root/OpenClashManage/wangluo
```

4. **启动服务**
```bash
cd /root/OpenClashManage
./jk.sh &
```

## 配置说明

### 节点文件格式

编辑 `/root/OpenClashManage/wangluo/nodes.txt`：

```txt
# Shadowsocks
ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@server:port#节点名称

# VMess
vmess://eyJhZGQiOiJzZXJ2ZXIiLCJwb3J0IjoiMTIzNCIsImlkIjoiVVVJRCIsImFpZCI6IjAiLCJuZXQiOiJ0Y3AiLCJ0eXBlIjoibm9uZSJ9#节点名称

# VLESS
vless://uuid@server:port?encryption=none#节点名称

# Trojan
trojan://password@server:port?security=tls#节点名称
```

### 支持的协议

| 协议 | 格式 | 说明 |
|------|------|------|
| Shadowsocks | `ss://` | 支持插件配置 |
| VMess | `vmess://` | 支持 TLS 和 WebSocket |
| VLESS | `vless://` | 支持流控和加密 |
| Trojan | `trojan://` | 支持 SNI 和证书验证 |

## 使用方法

### 基本操作

```bash
# 查看服务状态
/etc/init.d/openclash-sync status

# 手动同步节点
python3 /root/OpenClashManage/zr.py

# 查看实时日志
tail -f /root/OpenClashManage/wangluo/log.txt

# 编辑节点文件
vim /root/OpenClashManage/wangluo/nodes.txt
```

### Web 管理界面

访问：`http://你的路由器IP/cgi-bin/luci/admin/services/openclash`

功能包括：
- 运行状态监控
- 配置文件管理
- 规则管理
- 节点管理
- 策略组管理

### 常用命令

```bash
# 重启同步服务
/etc/init.d/openclash-sync restart

# 查看节点数量
grep -c "name:" /etc/openclash/config.yaml

# 测试节点连接
curl -x socks5://127.0.0.1:7890 http://www.google.com

# 查看系统日志
logread | grep openclash
```

## 故障排除

### 常见问题

#### 1. 节点同步失败
```bash
# 检查节点文件格式
cat /root/OpenClashManage/wangluo/nodes.txt

# 查看详细错误日志
tail -f /root/OpenClashManage/wangluo/log.txt
```

#### 2. OpenClash 启动失败
```bash
# 验证配置文件
/etc/init.d/openclash verify_config /etc/openclash/config.yaml

# 查看启动日志
logread | grep "Parse config error"
```

#### 3. 服务无法启动
```bash
# 检查进程锁
ls -la /tmp/openclash_update.lock

# 清理锁文件
rm -f /tmp/openclash_update.lock

# 重启服务
/etc/init.d/openclash-sync restart
```

### 日志分析

#### 成功日志示例
```
[2024-01-01 12:00:00] ✅ [parse] 成功解析 50 条，失败 2 条
[2024-01-01 12:00:01] ✅ [zw] 成功注入 48 个节点
[2024-01-01 12:00:02] ✅ [zc] 成功注入 5 个策略组，总计 48 个节点
```

#### 错误日志示例
```
[2024-01-01 12:00:00] ❌ [parse] 解析失败 (ss://invalid#节点) → Base64解码失败
[2024-01-01 12:00:01] ⚠️ [zw] 非法节点名已跳过：节点@名称
```

## 高级配置

### 自定义路径

修改 `jk.sh` 中的路径配置：

```bash
ROOT_DIR="/root/OpenClashManage"
NODES_FILE="$ROOT_DIR/wangluo/nodes.txt"
CONFIG_FILE="/etc/openclash/config.yaml"
```

### 调整同步间隔

修改 `jk.sh` 中的检查间隔：

```bash
INTERVAL=5  # 秒，可根据需要调整
```

### 自定义策略组

修改 `zc.py` 中的过滤规则：

```python
def should_inject_group(group_name: str, group_config: dict) -> bool:
    # 添加自定义过滤规则
    custom_groups = {"我的策略组1", "我的策略组2"}
    if group_name in custom_groups:
        return True
    # ... 其他规则
```

## 卸载

### 一键卸载

```bash
# 下载卸载脚本
wget https://raw.githubusercontent.com/your-repo/OpenClashManage/main/uninstall.sh

# 运行卸载脚本
chmod +x uninstall.sh
./uninstall.sh
```

### 手动卸载

```bash
# 停止服务
/etc/init.d/openclash-sync stop
/etc/init.d/openclash-sync disable

# 删除文件
rm -rf /root/OpenClashManage
rm -f /etc/init.d/openclash-sync

# 清理进程
pkill -f "jk.sh"
pkill -f "zr.py"
```

## 更新日志

### v1.0.0
- 初始版本发布
- 支持 4 种代理协议
- 自动同步和配置验证
- Web 管理界面集成

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 支持

如有问题，请查看：
1. 日志文件：`/root/OpenClashManage/wangluo/log.txt`
2. 系统日志：`logread | grep openclash`
3. 配置文件：`/etc/openclash/config.yaml` 