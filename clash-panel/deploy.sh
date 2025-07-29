#!/bin/bash

# FastAPI + Vue.js Clash 管理面板部署脚本
# 版本: 2.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }
log_success() { echo -e "${CYAN}[SUCCESS]${NC} $1"; }

# 显示横幅
show_banner() {
    echo
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                FastAPI + Vue.js Clash 管理面板                ║"
    echo "║                        部署脚本 v2.0                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo
}

# 检查系统
check_system() {
    log_step "检查系统环境..."
    
    # 检查是否为 OpenWrt
    if [ -f "/etc/openwrt_release" ]; then
        log_info "检测到 OpenWrt 系统"
        SYSTEM_TYPE="openwrt"
    elif [ -f "/etc/debian_version" ]; then
        log_info "检测到 Debian/Ubuntu 系统"
        SYSTEM_TYPE="debian"
    else
        log_warn "未知系统类型，将使用通用安装方式"
        SYSTEM_TYPE="generic"
    fi
    
    # 检查 Python 3
    if ! command -v python3 &> /dev/null; then
        log_error "需要安装 Python 3"
        exit 1
    fi
    
    # 检查 pip3
    if ! command -v pip3 &> /dev/null; then
        log_error "需要安装 pip3"
        exit 1
    fi
    
    log_success "系统检查通过"
}

# 安装 Python 依赖
install_python_deps() {
    log_step "安装 Python 依赖..."
    
    # 升级 pip
    pip3 install --upgrade pip
    
    # 安装依赖
    pip3 install fastapi uvicorn pyyaml python-multipart aiofiles
    
    log_success "Python 依赖安装完成"
}

# 创建目录结构
create_directories() {
    log_step "创建目录结构..."
    
    mkdir -p /opt/clash-panel
    mkdir -p /opt/clash-panel/backend
    mkdir -p /opt/clash-panel/frontend
    mkdir -p /opt/clash-panel/static
    mkdir -p /opt/clash-panel/logs
    mkdir -p /opt/clash-panel/backups
    
    log_success "目录创建完成"
}

# 复制应用文件
copy_application_files() {
    log_step "复制应用文件..."
    
    # 复制后端文件
    cp backend/main.py /opt/clash-panel/backend/
    cp requirements.txt /opt/clash-panel/
    
    # 复制前端文件
    cp frontend/index.html /opt/clash-panel/frontend/
    cp frontend/app.js /opt/clash-panel/frontend/
    
    # 复制 Docker 文件（如果使用 Docker）
    if [ -f "Dockerfile" ]; then
        cp Dockerfile /opt/clash-panel/
    fi
    if [ -f "docker-compose.yml" ]; then
        cp docker-compose.yml /opt/clash-panel/
    fi
    
    # 设置权限
    chmod +x /opt/clash-panel/backend/main.py
    chmod 755 /opt/clash-panel/frontend/*
    
    log_success "应用文件复制完成"
}

# 创建配置文件
create_config() {
    log_step "创建配置文件..."
    
    cat > /opt/clash-panel/config.json << 'EOF'
{
    "server": {
        "host": "0.0.0.0",
        "port": 8000,
        "debug": false
    },
    "clash": {
        "config_path": "/etc/openclash/config.yaml",
        "service_name": "openclash",
        "log_path": "/root/OpenClashManage/wangluo/log.txt"
    },
    "security": {
        "enable_auth": false,
        "username": "admin",
        "password": "admin123"
    },
    "ui": {
        "title": "Clash 管理面板",
        "theme": "default",
        "auto_refresh": 30
    }
}
EOF

    log_success "配置文件创建完成"
}

# 创建系统服务
create_system_service() {
    log_step "创建系统服务..."
    
    if [ "$SYSTEM_TYPE" = "openwrt" ]; then
        # OpenWrt 服务文件
        cat > /etc/init.d/clash-panel << 'EOF'
#!/bin/sh /etc/rc.common

START=99
STOP=15
USE_PROCD=1

start_service() {
    procd_open_instance
    procd_set_param command /usr/bin/python3 /opt/clash-panel/backend/main.py
    procd_set_param respawn
    procd_set_param stdout 1
    procd_set_param stderr 1
    procd_close_instance
}

stop_service() {
    pkill -f "main.py"
}
EOF
        chmod +x /etc/init.d/clash-panel
    else
        # 通用 systemd 服务文件
        cat > /etc/systemd/system/clash-panel.service << 'EOF'
[Unit]
Description=Clash Management Panel
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/clash-panel
ExecStart=/usr/bin/python3 /opt/clash-panel/backend/main.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
    fi
    
    log_success "系统服务创建完成"
}

# 配置防火墙
configure_firewall() {
    log_step "配置防火墙..."
    
    if [ "$SYSTEM_TYPE" = "openwrt" ]; then
        # OpenWrt 防火墙配置
        if command -v uci &> /dev/null; then
            uci add firewall rule
            uci set firewall.@rule[-1].name='ClashPanel'
            uci set firewall.@rule[-1].src='wan'
            uci set firewall.@rule[-1].proto='tcp'
            uci set firewall.@rule[-1].dest_port='8000'
            uci set firewall.@rule[-1].target='ACCEPT'
            uci commit firewall
            /etc/init.d/firewall restart
        fi
    else
        # 通用防火墙配置
        if command -v ufw &> /dev/null; then
            ufw allow 8000/tcp
        elif command -v iptables &> /dev/null; then
            iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
        fi
    fi
    
    log_success "防火墙配置完成"
}

# 启动服务
start_services() {
    log_step "启动服务..."
    
    if [ "$SYSTEM_TYPE" = "openwrt" ]; then
        /etc/init.d/clash-panel enable
        /etc/init.d/clash-panel start
    else
        systemctl daemon-reload
        systemctl enable clash-panel
        systemctl start clash-panel
    fi
    
    # 等待服务启动
    sleep 3
    
    # 检查服务状态
    if pgrep -f "main.py" > /dev/null; then
        log_success "服务启动成功"
    else
        log_error "服务启动失败"
        exit 1
    fi
}

# 显示安装信息
show_installation_info() {
    log_step "安装完成！"
    echo
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    安装信息                                   ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║ 📁 安装目录: /opt/clash-panel                               ║"
    echo "║ 🌐 访问地址: http://$(hostname -I | awk '{print $1}'):8000  ║"
    echo "║ 📋 配置文件: /opt/clash-panel/config.json                   ║"
    echo "║ 📝 日志文件: /opt/clash-panel/logs/                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo
    echo "📋 常用命令:"
    if [ "$SYSTEM_TYPE" = "openwrt" ]; then
        echo "   查看状态: /etc/init.d/clash-panel status"
        echo "   重启服务: /etc/init.d/clash-panel restart"
        echo "   停止服务: /etc/init.d/clash-panel stop"
    else
        echo "   查看状态: systemctl status clash-panel"
        echo "   重启服务: systemctl restart clash-panel"
        echo "   停止服务: systemctl stop clash-panel"
    fi
    echo "   查看日志: tail -f /opt/clash-panel/logs/clash-panel.log"
    echo
    echo "⚠️  重要提醒:"
    echo "   1. 确保 OpenClash 已安装并运行"
    echo "   2. 检查防火墙设置确保端口 8000 开放"
    echo "   3. 首次访问可能需要等待几秒钟"
    echo "   4. 默认无需认证，建议在生产环境中启用认证"
    echo
    echo "🔧 故障排除:"
    echo "   如果无法访问，请检查:"
    echo "   - 服务状态: pgrep -f main.py"
    echo "   - 端口监听: netstat -tlnp | grep 8000"
    echo "   - 防火墙规则: iptables -L | grep 8000"
    echo
}

# 主函数
main() {
    show_banner
    
    check_system
    install_python_deps
    create_directories
    copy_application_files
    create_config
    create_system_service
    configure_firewall
    start_services
    show_installation_info
}

# 错误处理
trap 'log_error "部署过程中发生错误，请检查日志"; exit 1' ERR

# 运行主函数
main "$@" 