#!/bin/bash

# Clash 管理面板安装脚本
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
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        log_error "需要安装 Docker"
        exit 1
    fi
    
    # 检查 Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "需要安装 Docker Compose"
        exit 1
    fi
    
    log_info "系统检查通过"
}

# 安装 Python 依赖
install_python_deps() {
    log_step "安装 Python 依赖..."
    
    # 安装 Python 3
    if ! command -v python3 &> /dev/null; then
        log_info "安装 Python 3..."
        opkg update
        opkg install python3 python3-pip
    fi
    
    # 安装 Python 包
    pip3 install fastapi uvicorn pyyaml python-multipart aiofiles
    
    log_info "Python 依赖安装完成"
}

# 创建目录结构
create_directories() {
    log_step "创建目录结构..."
    
    mkdir -p /opt/clash-panel
    mkdir -p /opt/clash-panel/backend
    mkdir -p /opt/clash-panel/frontend
    mkdir -p /opt/clash-panel/static
    
    log_info "目录创建完成"
}

# 复制文件
copy_files() {
    log_step "复制应用文件..."
    
    # 复制后端文件
    cp backend/main.py /opt/clash-panel/backend/
    cp requirements.txt /opt/clash-panel/
    
    # 复制前端文件
    cp frontend/index.html /opt/clash-panel/frontend/
    cp frontend/app.js /opt/clash-panel/frontend/
    
    # 复制 Docker 文件
    cp Dockerfile /opt/clash-panel/
    cp docker-compose.yml /opt/clash-panel/
    
    # 设置权限
    chmod +x /opt/clash-panel/backend/main.py
    
    log_info "文件复制完成"
}

# 创建服务文件
create_service() {
    log_step "创建系统服务..."
    
    cat > /etc/init.d/clash-panel << 'EOF'
#!/bin/sh /etc/rc.common

START=99
STOP=15

start() {
    echo "启动 Clash 管理面板..."
    cd /opt/clash-panel
    python3 backend/main.py > /dev/null 2>&1 &
    echo $! > /var/run/clash-panel.pid
}

stop() {
    echo "停止 Clash 管理面板..."
    if [ -f /var/run/clash-panel.pid ]; then
        kill $(cat /var/run/clash-panel.pid) 2>/dev/null || true
        rm -f /var/run/clash-panel.pid
    fi
    pkill -f "main.py" 2>/dev/null || true
}

restart() {
    stop
    sleep 2
    start
}
EOF

    chmod +x /etc/init.d/clash-panel
    
    log_info "服务文件创建完成"
}

# 配置防火墙
configure_firewall() {
    log_step "配置防火墙..."
    
    if command -v uci &> /dev/null; then
        # 添加防火墙规则
        uci add firewall rule
        uci set firewall.@rule[-1].name='ClashPanel'
        uci set firewall.@rule[-1].src='wan'
        uci set firewall.@rule[-1].proto='tcp'
        uci set firewall.@rule[-1].dest_port='8000'
        uci set firewall.@rule[-1].target='ACCEPT'
        uci commit firewall
        /etc/init.d/firewall restart
    fi
    
    log_info "防火墙配置完成"
}

# 启动服务
start_services() {
    log_step "启动服务..."
    
    # 启用并启动服务
    /etc/init.d/clash-panel enable
    /etc/init.d/clash-panel start
    
    log_info "服务启动完成"
}

# 显示安装信息
show_info() {
    log_step "安装完成！"
    echo
    echo "=========================================="
    echo "           Clash 管理面板"
    echo "=========================================="
    echo
    echo "📁 安装目录: /opt/clash-panel"
    echo "🌐 访问地址: http://$(uci get network.lan.ipaddr 2>/dev/null || echo '你的路由器IP'):8000"
    echo
    echo "📋 常用命令:"
    echo "   查看状态: /etc/init.d/clash-panel status"
    echo "   重启服务: /etc/init.d/clash-panel restart"
    echo "   查看日志: tail -f /var/log/clash-panel.log"
    echo
    echo "⚠️  重要提醒:"
    echo "   1. 确保 OpenClash 已安装并运行"
    echo "   2. 检查防火墙设置确保端口 8000 开放"
    echo "   3. 首次访问可能需要等待几秒钟"
    echo
    echo "=========================================="
}

# 主函数
main() {
    echo "=========================================="
    echo "      Clash 管理面板安装"
    echo "=========================================="
    echo
    
    check_root
    check_system
    install_python_deps
    create_directories
    copy_files
    create_service
    configure_firewall
    start_services
    show_info
}

# 错误处理
trap 'log_error "安装过程中发生错误，请检查日志"; exit 1' ERR

# 运行主函数
main "$@" 