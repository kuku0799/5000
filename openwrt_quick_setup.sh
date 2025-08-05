#!/bin/bash

# OpenClash节点管理系统 - OpenWrt快速设置脚本
# 专门为OpenWrt系统优化，无需sudo

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
            log_info "请确保在正确的目录中运行此脚本"
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
    
    # OpenWrt使用opkg
    opkg update
    opkg install python3 python3-pip
    
    # 安装Python依赖
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
    
    # 创建守护进程服务
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

    # 创建Web编辑器服务
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

    # 重新加载systemd
    systemctl daemon-reload
    
    # 启用服务
    systemctl enable openclash-manager-watchdog.service
    systemctl enable openclash-manager-web.service
    
    # 启动服务
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
    
    # 检查rc.local是否存在
    if [[ ! -f /etc/rc.local ]]; then
        cat > /etc/rc.local << EOF
#!/bin/bash
cd $current_dir
python3 web_editor.py > /dev/null 2>&1 &
bash jk.sh > /dev/null 2>&1 &
exit 0
EOF
    else
        # 在exit 0之前添加启动命令
        sed -i '/^exit 0/i cd '"$current_dir"'\npython3 web_editor.py > /dev/null 2>&1 &\nbash jk.sh > /dev/null 2>&1 &' /etc/rc.local
    fi
    
    chmod +x /etc/rc.local
    
    # 立即启动服务
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
    echo "=== 服务状态 ==="
    if command -v systemctl &> /dev/null; then
        systemctl status openclash-manager-watchdog.service --no-pager -l 2>/dev/null || echo "systemd服务未找到"
        systemctl status openclash-manager-web.service --no-pager -l 2>/dev/null || echo "systemd服务未找到"
    fi
    
    if [[ -f /etc/init.d/openclash-manager ]]; then
        /etc/init.d/openclash-manager status 2>/dev/null || echo "init.d服务状态检查失败"
    fi
    
    echo ""
    echo "=== 访问信息 ==="
    local ip=$(hostname -I | awk '{print $1}')
    echo "Web编辑器地址: http://$ip:5000"
}

# 启动服务
start_services() {
    log_step "启动服务..."
    
    if command -v systemctl &> /dev/null; then
        systemctl start openclash-manager-watchdog.service 2>/dev/null || true
        systemctl start openclash-manager-web.service 2>/dev/null || true
    fi
    
    if [[ -f /etc/init.d/openclash-manager ]]; then
        /etc/init.d/openclash-manager start
    fi
    
    # 直接启动进程
    cd "$(pwd)"
    python3 web_editor.py > /dev/null 2>&1 &
    bash jk.sh > /dev/null 2>&1 &
    
    log_info "服务已启动"
}

# 停止服务
stop_services() {
    log_step "停止服务..."
    
    if command -v systemctl &> /dev/null; then
        systemctl stop openclash-manager-watchdog.service 2>/dev/null || true
        systemctl stop openclash-manager-web.service 2>/dev/null || true
    fi
    
    if [[ -f /etc/init.d/openclash-manager ]]; then
        /etc/init.d/openclash-manager stop
    fi
    
    # 直接停止进程
    pkill -f "web_editor.py" 2>/dev/null || true
    pkill -f "jk.sh" 2>/dev/null || true
    
    log_info "服务已停止"
}

# 重启服务
restart_services() {
    log_step "重启服务..."
    stop_services
    sleep 2
    start_services
    log_info "服务已重启"
}

# 卸载服务
uninstall_services() {
    log_step "卸载服务..."
    
    # 停止服务
    stop_services
    
    # 删除systemd服务
    if command -v systemctl &> /dev/null; then
        systemctl disable openclash-manager-watchdog.service 2>/dev/null || true
        systemctl disable openclash-manager-web.service 2>/dev/null || true
        rm -f /etc/systemd/system/openclash-manager-watchdog.service
        rm -f /etc/systemd/system/openclash-manager-web.service
        systemctl daemon-reload
    fi
    
    # 删除init.d服务
    if [[ -f /etc/init.d/openclash-manager ]]; then
        /etc/init.d/openclash-manager disable 2>/dev/null || true
        rm -f /etc/init.d/openclash-manager
    fi
    
    log_info "服务已卸载"
}

# 显示帮助
show_help() {
    echo "OpenClash节点管理系统 - OpenWrt快速设置脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  install    安装并启动服务（推荐）"
    echo "  systemd    使用systemd服务"
    echo "  initd      使用init.d脚本"
    echo "  rclocal    使用rc.local"
    echo "  start      启动服务"
    echo "  stop       停止服务"
    echo "  restart    重启服务"
    echo "  status     显示服务状态"
    echo "  uninstall  卸载服务"
    echo "  help       显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 install   # 安装并启动服务"
    echo "  $0 status    # 查看状态"
    echo "  $0 restart   # 重启服务"
}

# 主函数
main() {
    case "${1:-install}" in
        install)
            log_info "开始安装OpenClash节点管理系统..."
            check_files
            set_permissions
            install_dependencies
            
            # 自动选择最佳方法
            if command -v systemctl &> /dev/null; then
                create_systemd_services
            else
                create_initd_service
            fi
            
            show_status
            log_info "安装完成！"
            ;;
        systemd)
            log_info "使用systemd设置..."
            check_files
            set_permissions
            install_dependencies
            create_systemd_services
            show_status
            ;;
        initd)
            log_info "使用init.d设置..."
            check_files
            set_permissions
            install_dependencies
            create_initd_service
            show_status
            ;;
        rclocal)
            log_info "使用rc.local设置..."
            check_files
            set_permissions
            install_dependencies
            create_rclocal
            show_status
            ;;
        start)
            start_services
            show_status
            ;;
        stop)
            stop_services
            ;;
        restart)
            restart_services
            show_status
            ;;
        status)
            show_status
            ;;
        uninstall)
            uninstall_services
            ;;
        help)
            show_help
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@" 