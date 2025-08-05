# 🚀 传统OpenWrt系统解决方案

## 📋 问题分析

您的OpenWrt系统没有systemctl，这说明您使用的是传统的init.d系统。这是正常的，因为很多OpenWrt版本仍然使用传统的init系统。

## 🔧 解决方案

### 方法1：使用init.d脚本（推荐）

```bash
# 给脚本执行权限
chmod +x openwrt_initd_setup.sh

# 安装并启动服务
./openwrt_initd_setup.sh install

# 查看状态
./openwrt_initd_setup.sh status

# 重启服务
./openwrt_initd_setup.sh restart
```

### 方法2：手动创建init.d服务

```bash
# 1. 设置文件权限
chmod +x jk.sh web_editor.py zr.py jx.py zw.py zc.py log.py

# 2. 安装依赖
opkg update
opkg install python3 python3-pip
pip3 install flask

# 3. 创建init.d服务
cat > /etc/init.d/openclash-manager << 'EOF'
#!/bin/sh /etc/rc.common

START=99
STOP=10

start() {
    echo "启动OpenClash节点管理系统..."
    cd /root/OpenClashManage
    python3 web_editor.py > /dev/null 2>&1 &
    bash jk.sh > /dev/null 2>&1 &
    echo "服务已启动"
}

stop() {
    echo "停止OpenClash节点管理系统..."
    pkill -f "web_editor.py"
    pkill -f "jk.sh"
    echo "服务已停止"
}

restart() {
    stop
    sleep 2
    start
}
EOF

# 4. 设置执行权限并启用
chmod +x /etc/init.d/openclash-manager
/etc/init.d/openclash-manager enable
/etc/init.d/openclash-manager start
```

### 方法3：使用rc.local（最简单）

```bash
# 1. 设置文件权限
chmod +x jk.sh web_editor.py zr.py jx.py zw.py zc.py log.py

# 2. 安装依赖
opkg update
opkg install python3 python3-pip
pip3 install flask

# 3. 编辑rc.local
cat > /etc/rc.local << 'EOF'
#!/bin/bash
cd /root/OpenClashManage
python3 web_editor.py > /dev/null 2>&1 &
bash jk.sh > /dev/null 2>&1 &
exit 0
EOF

# 4. 设置执行权限
chmod +x /etc/rc.local

# 5. 立即启动服务
cd /root/OpenClashManage
python3 web_editor.py > /dev/null 2>&1 &
bash jk.sh > /dev/null 2>&1 &
```

## 📊 服务管理命令

### 使用init.d命令
```bash
# 启动服务
/etc/init.d/openclash-manager start

# 停止服务
/etc/init.d/openclash-manager stop

# 重启服务
/etc/init.d/openclash-manager restart

# 查看状态
/etc/init.d/openclash-manager status

# 启用开机自启动
/etc/init.d/openclash-manager enable

# 禁用开机自启动
/etc/init.d/openclash-manager disable
```

### 查看日志
```bash
# 查看系统日志
tail -f /var/log/messages

# 查看进程
ps aux | grep -E "(web_editor|jk.sh)"
```

## 🔍 验证安装

### 检查进程
```bash
# 查看进程状态
ps aux | grep -E "(web_editor|jk.sh)"

# 查看端口
netstat -tlnp | grep :5000
```

### 检查服务状态
```bash
# 检查init.d服务
/etc/init.d/openclash-manager status

# 检查服务是否启用
ls -la /etc/rc.d/S*openclash-manager
```

## 🌐 访问Web界面

### 获取IP地址
```bash
# 获取路由器IP
hostname -I
ip addr show
```

### 访问Web编辑器
- 在浏览器中输入：`http://你的路由器IP:5000`
- 例如：`http://192.168.1.1:5000`

## 🔧 故障排除

### 常见问题

#### 1. 服务启动失败
```bash
# 检查依赖
python3 --version
pip3 --version

# 检查文件权限
ls -la /root/OpenClashManage/

# 检查端口占用
netstat -tlnp | grep :5000
```

#### 2. 开机不自动启动
```bash
# 检查服务是否启用
ls -la /etc/rc.d/S*openclash-manager

# 重新启用服务
/etc/init.d/openclash-manager enable
```

#### 3. 权限问题
```bash
# 确保脚本有执行权限
chmod +x /root/OpenClashManage/*.sh
chmod +x /root/OpenClashManage/*.py

# 检查用户权限
whoami
id
```

#### 4. 端口冲突
```bash
# 检查端口占用
lsof -i :5000

# 修改端口（编辑web_editor.py）
nano /root/OpenClashManage/web_editor.py
# 修改 app.run(host='0.0.0.0', port=5000) 中的端口号
```

## 📈 性能监控

### 资源使用
```bash
# 监控CPU和内存使用
top -p $(pgrep -f "web_editor\|jk.sh")

# 监控磁盘使用
df -h

# 监控网络连接
netstat -an | grep :5000
```

## 🔒 安全配置

### 防火墙设置
```bash
# 开放Web编辑器端口
iptables -A INPUT -p tcp --dport 5000 -j ACCEPT

# 保存防火墙规则
iptables-save > /etc/config/firewall
```

### 访问控制
```bash
# 限制访问IP（在web_editor.py中修改）
# app.run(host='0.0.0.0', port=5000) 改为
# app.run(host='127.0.0.1', port=5000)
```

## 📞 技术支持

### 获取帮助
```bash
# 查看脚本帮助
./openwrt_initd_setup.sh help

# 查看服务状态
./openwrt_initd_setup.sh status

# 查看系统日志
tail -f /var/log/messages
```

### 问题反馈
- 检查服务状态：`/etc/init.d/openclash-manager status`
- 查看错误日志：`tail -f /var/log/messages`
- 重启服务：`/etc/init.d/openclash-manager restart`

## 🎯 快速开始

### 一键安装
```bash
# 下载并运行设置脚本
wget -O - https://raw.githubusercontent.com/kuku0799/5000/main/openwrt_initd_setup.sh | bash

# 或者直接运行
chmod +x openwrt_initd_setup.sh
./openwrt_initd_setup.sh install
```

### 验证安装
```bash
# 查看服务状态
./openwrt_initd_setup.sh status

# 查看进程
ps aux | grep -E "(web_editor|jk.sh)"

# 访问Web界面
# 在浏览器中访问: http://你的路由器IP:5000
```

---

**总结**：您的OpenWrt系统使用传统的init.d系统是正常的。推荐使用 `./openwrt_initd_setup.sh install` 来设置自动启动，这个脚本专门为传统OpenWrt系统优化。 