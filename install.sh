#!/bin/bash

# OpenClash 管理系统一键部署脚本
# 作者: AI Assistant
# 版本: 1.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检查是否为 root 用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要 root 权限运行"
        exit 1
    fi
}

# 检查系统
check_system() {
    log_step "检查系统环境..."
    
    if ! command -v opkg &> /dev/null; then
        log_error "此脚本仅支持 OpenWrt 系统"
        exit 1
    fi
    
    log_info "系统检查通过"
}

# 安装 OpenClash
install_openclash() {
    log_step "安装 OpenClash..."
    
    # 更新软件包列表
    log_info "更新软件包列表..."
    opkg update
    
    # 安装 OpenClash
    if ! opkg list-installed | grep -q "luci-app-openclash"; then
        log_info "安装 luci-app-openclash..."
        opkg install luci-app-openclash
    else
        log_info "OpenClash 已安装"
    fi
    
    # 安装 Python 依赖
    log_info "安装 Python 依赖..."
    opkg install python3 python3-pip python3-yaml
    
    # 安装 Python 包
    pip3 install ruamel.yaml
    
    log_info "OpenClash 安装完成"
}

# 创建目录结构
create_directories() {
    log_step "创建目录结构..."
    
    # 创建主目录
    mkdir -p /root/OpenClashManage
    mkdir -p /root/OpenClashManage/wangluo
    
    log_info "目录创建完成"
}

# 复制脚本文件
copy_scripts() {
    log_step "复制脚本文件..."
    
    # 检查当前目录是否有脚本文件
    if [[ ! -f "jk.sh" ]]; then
        log_error "未找到脚本文件，请确保在正确的目录中运行此脚本"
        exit 1
    fi
    
    # 复制脚本文件
    cp jk.sh zr.py jx.py zw.py zc.py log.py /root/OpenClashManage/
    
    # 设置执行权限
    chmod +x /root/OpenClashManage/*.sh
    chmod +x /root/OpenClashManage/*.py
    
    log_info "脚本文件复制完成"
}

# 创建服务文件
create_service() {
    log_step "创建系统服务..."
    
    cat > /etc/init.d/openclash-sync << 'EOF'
#!/bin/sh /etc/rc.common

START=99
STOP=15

start() {
    echo "启动 OpenClash 同步服务..."
    cd /root/OpenClashManage
    nohup ./jk.sh > /dev/null 2>&1 &
    echo $! > /var/run/openclash-sync.pid
}

stop() {
    echo "停止 OpenClash 同步服务..."
    if [ -f /var/run/openclash-sync.pid ]; then
        kill $(cat /var/run/openclash-sync.pid) 2>/dev/null || true
        rm -f /var/run/openclash-sync.pid
    fi
    # 停止所有相关进程
    pkill -f "jk.sh" 2>/dev/null || true
}

restart() {
    stop
    sleep 2
    start
}
EOF

    chmod +x /etc/init.d/openclash-sync
    
    log_info "服务文件创建完成"
}

# 创建示例节点文件
create_sample_nodes() {
    log_step "创建示例节点文件..."
    
    cat > /root/OpenClashManage/wangluo/nodes.txt << 'EOF'
# 示例节点文件
# 请将你的节点链接粘贴到这里
# 支持格式: ss://, vmess://, vless://, trojan://

# Shadowsocks 示例
# ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@server:port#节点名称

# VMess 示例  
# vmess://eyJhZGQiOiJzZXJ2ZXIiLCJwb3J0IjoiMTIzNCIsImlkIjoiVVVJRCIsImFpZCI6IjAiLCJuZXQiOiJ0Y3AiLCJ0eXBlIjoibm9uZSJ9#节点名称

# VLESS 示例
# vless://uuid@server:port?encryption=none#节点名称

# Trojan 示例
# trojan://password@server:port?security=tls#节点名称
EOF

    log_info "示例节点文件创建完成"
}

# 配置防火墙
configure_firewall() {
    log_step "配置防火墙..."
    
    # 添加防火墙规则（如果需要）
    if command -v uci &> /dev/null; then
        # 确保 OpenClash 端口开放
        uci add firewall rule
        uci set firewall.@rule[-1].name='OpenClash'
        uci set firewall.@rule[-1].src='wan'
        uci set firewall.@rule[-1].proto='tcp'
        uci set firewall.@rule[-1].dest_port='7890'
        uci set firewall.@rule[-1].target='ACCEPT'
        uci commit firewall
        /etc/init.d/firewall restart
    fi
    
    log_info "防火墙配置完成"
}

# 启动服务
start_services() {
    log_step "启动服务..."
    
    # 启用并启动同步服务
    /etc/init.d/openclash-sync enable
    /etc/init.d/openclash-sync start
    
    # 重启 LuCI
    /etc/init.d/uhttpd restart
    
    log_info "服务启动完成"
}

# 显示安装信息
show_info() {
    log_step "安装完成！"
    echo
    echo "=========================================="
    echo "           OpenClash 管理系统"
    echo "=========================================="
    echo
    echo "📁 安装目录: /root/OpenClashManage"
    echo "📝 节点文件: /root/OpenClashManage/wangluo/nodes.txt"
    echo "📋 日志文件: /root/OpenClashManage/wangluo/log.txt"
    echo
    echo "🌐 管理界面: http://$(uci get network.lan.ipaddr 2>/dev/null || echo '你的路由器IP')/cgi-bin/luci/admin/services/openclash"
    echo
    echo "📋 常用命令:"
    echo "   查看状态: /etc/init.d/openclash-sync status"
    echo "   手动同步: python3 /root/OpenClashManage/zr.py"
    echo "   查看日志: tail -f /root/OpenClashManage/wangluo/log.txt"
    echo "   编辑节点: vim /root/OpenClashManage/wangluo/nodes.txt"
    echo
    echo "⚠️  重要提醒:"
    echo "   1. 请编辑 /root/OpenClashManage/wangluo/nodes.txt 添加你的节点"
    echo "   2. 访问管理界面进行初始配置"
    echo "   3. 检查防火墙设置确保端口开放"
    echo
    echo "=========================================="
}

# 主函数
main() {
    echo "=========================================="
    echo "      OpenClash 管理系统一键部署"
    echo "=========================================="
    echo
    
    check_root
    check_system
    install_openclash
    create_directories
    copy_scripts
    create_service
    create_sample_nodes
    configure_firewall
    start_services
    show_info
}

# 错误处理
trap 'log_error "安装过程中发生错误，请检查日志"; exit 1' ERR

# 运行主函数
main "$@" 