#!/bin/bash

# OpenClash节点管理系统 - 完整开机自启动部署脚本
# 支持多种系统：OpenWrt、Ubuntu、Debian、CentOS等

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 显示横幅
show_banner() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                OpenClash节点管理系统                          ║"
    echo "║                    开机自启动部署脚本                         ║"
    echo "║                                                              ║"
    echo "║  支持系统: OpenWrt, Ubuntu, Debian, CentOS, RHEL           ║"
    echo "║  自动检测: systemd, init.d, rc.local, procd                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
}

# 检测系统类型
detect_system() {
    log_step "检测系统类型..."
    
    if [[ -f /etc/openwrt_release ]]; then
        SYSTEM="openwrt"
        log_info "检测到系统: OpenWrt"
    elif [[ -f /etc/debian_version ]]; then
        SYSTEM="debian"
        log_info "检测到系统: Debian/Ubuntu"
    elif [[ -f /etc/redhat-release ]]; then
        SYSTEM="redhat"
        log_info "检测到系统: CentOS/RHEL"
    else
        SYSTEM="unknown"
        log_warn "未知系统类型，将使用通用方法"
    fi
}

# 检测init系统
detect_init() {
    log_step "检测init系统..."
    
    if command -v systemctl &> /dev/null; then
        INIT="systemd"
        log_info "检测到init系统: systemd"
    elif command -v initctl &> /dev/null; then
        INIT="upstart"
        log_info "检测到init系统: upstart"
    else
        INIT="sysv"
        log_info "检测到init系统: sysv (传统init.d)"
    fi
}

# 检查必要文件
check_files() {
    log_step "检查必要文件..."
    
    local required_files=(
        "jk.sh"
        "web_editor.py"
        "zr.py"
        "jx.py"
        "zw.py"
        "zc.py"
        "log.py"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "缺少必要文件: $file"
            exit 1
        fi
    done
    
    log_info "所有必要文件检查通过"
}

# 设置文件权限
set_permissions() {
    log_step "设置文件权限..."
    
    chmod +x jk.sh
    chmod +x web_editor.py
    chmod +x zr.py
    chmod +x jx.py
    chmod +x zw.py
    chmod +x zc.py
    chmod +x log.py
    
    log_info "文件权限设置完成"
}

# 安装依赖
install_dependencies() {
    log_step "安装依赖..."
    
    if command -v opkg &> /dev/null; then
        opkg update
        opkg install python3 python3-pip
    elif command -v apt &> /dev/null; then
        apt update
        apt install -y python3 python3-pip
    elif command -v yum &> /dev/null; then
        yum install -y python3 python3-pip
    fi
    
    if [[ -f "requirements.txt" ]]; then
        pip3 install -r requirements.txt
    else
        pip3 install flask
    fi
    
    log_info "依赖安装完成"
}

# 创建systemd服务
create_systemd_services() {
    log_step "创建systemd服务..."
    
    local current_dir=$(pwd)
    
    cat > /etc/systemd/system/openclash-manager-watchdog.service << EOF
[Unit]
Description=OpenClash节点管理系统 - 守护进程
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$current_dir
ExecStart=/bin/bash $current_dir/jk.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    cat > /etc/systemd/system/openclash-manager-web.service << EOF
[Unit]
Description=OpenClash节点管理系统 - Web编辑器
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$current_dir
ExecStart=/usr/bin/python3 $current_dir/web_editor.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable openclash-manager-watchdog.service
    systemctl enable openclash-manager-web.service
    systemctl start openclash-manager-watchdog.service
    systemctl start openclash-manager-web.service
    
    log_info "systemd服务设置完成"
}

# 创建init.d服务
create_initd_service() {
    log_step "创建init.d服务..."
    
    local current_dir=$(pwd)
    
    cat > /etc/init.d/openclash-manager << EOF
#!/bin/sh /etc/rc.common

START=99
STOP=10

start() {
    echo "启动OpenClash节点管理系统..."
    cd $current_dir
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

    chmod +x /etc/init.d/openclash-manager
    /etc/init.d/openclash-manager enable
    /etc/init.d/openclash-manager start
    
    log_info "init.d服务设置完成"
}

# 创建rc.local启动
create_rclocal() {
    log_step "创建rc.local启动..."
    
    local current_dir=$(pwd)
    
    if [[ ! -f /etc/rc.local ]]; then
        cat > /etc/rc.local << EOF
#!/bin/bash
cd $current_dir
python3 web_editor.py > /dev/null 2>&1 &
bash jk.sh > /dev/null 2>&1 &
exit 0
EOF
    else
        sed -i '/^exit 0/i cd '"$current_dir"'\npython3 web_editor.py > /dev/null 2>&1 &\nbash jk.sh > /dev/null 2>&1 &' /etc/rc.local
    fi
    
    chmod +x /etc/rc.local
    
    cd "$current_dir"
    python3 web_editor.py > /dev/null 2>&1 &
    bash jk.sh > /dev/null 2>&1 &
    
    log_info "rc.local设置完成"
}

# 显示状态
show_status() {
    log_step "显示服务状态..."
    
    echo ""
    echo "=== 进程状态 ==="
    ps aux | grep -E "(web_editor|jk.sh)" | grep -v grep
    
    echo ""
    echo "=== 端口状态 ==="
    netstat -tlnp | grep :5000 2>/dev/null || echo "端口5000未监听"
    
    echo ""
    echo "=== 访问信息 ==="
    local ip=$(hostname -I | awk '{print $1}')
    echo "Web编辑器地址: http://$ip:5000"
}

# 主部署函数
deploy_auto_start() {
    show_banner
    
    detect_system
    detect_init
    check_files
    set_permissions
    install_dependencies
    
    case "$SYSTEM-$INIT" in
        openwrt-systemd)
            create_systemd_services
            ;;
        openwrt-sysv)
            create_initd_service
            ;;
        *-systemd)
            create_systemd_services
            ;;
        *-sysv)
            create_initd_service
            ;;
        *)
            create_rclocal
            ;;
    esac
    
    show_status
    
    log_info "部署完成！"
    echo ""
    echo "=== 管理命令 ==="
    if command -v systemctl &> /dev/null; then
        echo "启动: systemctl start openclash-manager-*.service"
        echo "停止: systemctl stop openclash-manager-*.service"
        echo "状态: systemctl status openclash-manager-*.service"
    else
        echo "启动: /etc/init.d/openclash-manager start"
        echo "停止: /etc/init.d/openclash-manager stop"
        echo "状态: /etc/init.d/openclash-manager status"
    fi
}

# 主函数
main() {
    case "${1:-deploy}" in
        deploy)
            deploy_auto_start
            ;;
        status)
            show_status
            ;;
        help)
            echo "用法: $0 [deploy|status|help]"
            ;;
        *)
            log_error "未知选项: $1"
            exit 1
            ;;
    esac
}

main "$@" 