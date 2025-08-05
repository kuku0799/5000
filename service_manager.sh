#!/bin/bash

# OpenClash节点管理系统 - 服务管理脚本
# 用于方便地管理systemd服务

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置
SERVICE_NAME="openclash-manager"
ROOT_DIR="/root/OpenClashManage"

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

# 显示帮助信息
show_help() {
    echo "🔧 OpenClash节点管理系统 - 服务管理工具"
    echo "========================================"
    echo
    echo "用法: $0 [命令]"
    echo
    echo "命令:"
    echo "  install     - 安装并启动服务"
    echo "  uninstall   - 卸载服务"
    echo "  start       - 启动服务"
    echo "  stop        - 停止服务"
    echo "  restart     - 重启服务"
    echo "  status      - 查看服务状态"
    echo "  logs        - 查看服务日志"
    echo "  enable      - 启用开机自启动"
    echo "  disable     - 禁用开机自启动"
    echo "  check       - 检查系统状态"
    echo "  help        - 显示此帮助信息"
    echo
    echo "示例:"
    echo "  $0 install    # 安装服务"
    echo "  $0 status     # 查看状态"
    echo "  $0 logs       # 查看日志"
    echo
}

# 检查root权限
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此命令需要root权限"
        exit 1
    fi
}

# 检查服务文件是否存在
check_service_files() {
    if [[ ! -f "/etc/systemd/system/${SERVICE_NAME}.service" ]]; then
        log_error "服务未安装，请先运行: $0 install"
        exit 1
    fi
}

# 安装服务
install_service() {
    log_step "安装服务..."
    check_root
    
    # 检查必要文件
    if [[ ! -f "$ROOT_DIR/jk.sh" ]] || [[ ! -f "$ROOT_DIR/web_editor.py" ]]; then
        log_error "缺少必要文件，请确保在正确的目录中运行"
        exit 1
    fi
    
    # 设置权限
    chmod +x "$ROOT_DIR/jk.sh"
    chmod +x "$ROOT_DIR/start_web_editor.sh"
    
    # 确保目录存在
    mkdir -p "$ROOT_DIR/wangluo"
    mkdir -p "$ROOT_DIR/templates"
    
    # 安装依赖
    if [[ -f "$ROOT_DIR/requirements.txt" ]]; then
        log_info "安装Python依赖..."
        pip3 install -r "$ROOT_DIR/requirements.txt"
    fi
    
    # 创建服务文件
    log_info "创建systemd服务文件..."
    
    # 守护进程服务
    cat > "/etc/systemd/system/${SERVICE_NAME}-watchdog.service" << EOF
[Unit]
Description=OpenClash节点管理系统 - 守护进程
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$ROOT_DIR
ExecStart=/bin/bash $ROOT_DIR/jk.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    # Web编辑器服务
    cat > "/etc/systemd/system/${SERVICE_NAME}-web.service" << EOF
[Unit]
Description=OpenClash节点管理系统 - Web编辑器
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$ROOT_DIR
ExecStart=/usr/bin/python3 $ROOT_DIR/web_editor.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
Environment=FLASK_ENV=production

[Install]
WantedBy=multi-user.target
EOF

    # 主服务
    cat > "/etc/systemd/system/${SERVICE_NAME}.service" << EOF
[Unit]
Description=OpenClash节点管理系统 - 完整系统
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'systemctl start ${SERVICE_NAME}-watchdog.service && systemctl start ${SERVICE_NAME}-web.service'
ExecStop=/bin/bash -c 'systemctl stop ${SERVICE_NAME}-watchdog.service && systemctl stop ${SERVICE_NAME}-web.service'

[Install]
WantedBy=multi-user.target
EOF

    # 重新加载systemd
    systemctl daemon-reload
    
    # 启用服务
    systemctl enable "${SERVICE_NAME}-watchdog.service"
    systemctl enable "${SERVICE_NAME}-web.service"
    systemctl enable "${SERVICE_NAME}.service"
    
    # 启动服务
    systemctl start "${SERVICE_NAME}.service"
    
    log_info "✅ 服务安装完成"
}

# 卸载服务
uninstall_service() {
    log_step "卸载服务..."
    check_root
    
    # 停止服务
    systemctl stop "${SERVICE_NAME}.service" 2>/dev/null || true
    systemctl stop "${SERVICE_NAME}-watchdog.service" 2>/dev/null || true
    systemctl stop "${SERVICE_NAME}-web.service" 2>/dev/null || true
    
    # 禁用服务
    systemctl disable "${SERVICE_NAME}.service" 2>/dev/null || true
    systemctl disable "${SERVICE_NAME}-watchdog.service" 2>/dev/null || true
    systemctl disable "${SERVICE_NAME}-web.service" 2>/dev/null || true
    
    # 删除服务文件
    rm -f "/etc/systemd/system/${SERVICE_NAME}.service"
    rm -f "/etc/systemd/system/${SERVICE_NAME}-watchdog.service"
    rm -f "/etc/systemd/system/${SERVICE_NAME}-web.service"
    
    # 重新加载systemd
    systemctl daemon-reload
    
    log_info "✅ 服务已卸载"
}

# 启动服务
start_service() {
    log_step "启动服务..."
    check_root
    check_service_files
    
    systemctl start "${SERVICE_NAME}.service"
    log_info "✅ 服务已启动"
}

# 停止服务
stop_service() {
    log_step "停止服务..."
    check_root
    check_service_files
    
    systemctl stop "${SERVICE_NAME}.service"
    log_info "✅ 服务已停止"
}

# 重启服务
restart_service() {
    log_step "重启服务..."
    check_root
    check_service_files
    
    systemctl restart "${SERVICE_NAME}.service"
    log_info "✅ 服务已重启"
}

# 查看服务状态
show_status() {
    log_step "服务状态..."
    
    echo
    echo "=== 主服务状态 ==="
    systemctl status "${SERVICE_NAME}.service" --no-pager -l
    
    echo
    echo "=== 守护进程状态 ==="
    systemctl status "${SERVICE_NAME}-watchdog.service" --no-pager -l
    
    echo
    echo "=== Web编辑器状态 ==="
    systemctl status "${SERVICE_NAME}-web.service" --no-pager -l
    
    echo
    echo "=== 进程检查 ==="
    if pgrep -f "jk.sh" > /dev/null; then
        log_info "✅ 守护进程正在运行"
    else
        log_warn "⚠️  守护进程未运行"
    fi
    
    if pgrep -f "web_editor.py" > /dev/null; then
        log_info "✅ Web编辑器进程正在运行"
    else
        log_warn "⚠️  Web编辑器进程未运行"
    fi
    
    echo
    echo "=== 端口检查 ==="
    if netstat -tlnp 2>/dev/null | grep -q ":5000 "; then
        log_info "✅ Web编辑器端口 5000 正在监听"
        log_info "🌐 访问地址: http://$(hostname -I | awk '{print $1}'):5000"
    else
        log_warn "⚠️  Web编辑器端口 5000 未监听"
    fi
}

# 查看服务日志
show_logs() {
    log_step "服务日志..."
    
    echo "=== 主服务日志 ==="
    journalctl -u "${SERVICE_NAME}.service" --no-pager -n 20
    
    echo
    echo "=== 守护进程日志 ==="
    journalctl -u "${SERVICE_NAME}-watchdog.service" --no-pager -n 20
    
    echo
    echo "=== Web编辑器日志 ==="
    journalctl -u "${SERVICE_NAME}-web.service" --no-pager -n 20
    
    echo
    echo "=== 实时日志跟踪 ==="
    echo "使用以下命令查看实时日志："
    echo "  journalctl -u ${SERVICE_NAME}.service -f"
    echo "  journalctl -u ${SERVICE_NAME}-watchdog.service -f"
    echo "  journalctl -u ${SERVICE_NAME}-web.service -f"
}

# 启用开机自启动
enable_autostart() {
    log_step "启用开机自启动..."
    check_root
    check_service_files
    
    systemctl enable "${SERVICE_NAME}.service"
    log_info "✅ 开机自启动已启用"
}

# 禁用开机自启动
disable_autostart() {
    log_step "禁用开机自启动..."
    check_root
    check_service_files
    
    systemctl disable "${SERVICE_NAME}.service"
    log_info "✅ 开机自启动已禁用"
}

# 检查系统状态
check_system() {
    log_step "系统状态检查..."
    
    echo "=== 系统信息 ==="
    echo "操作系统: $(uname -a)"
    echo "Python版本: $(python3 --version 2>/dev/null || echo '未安装')"
    echo "Pip版本: $(pip3 --version 2>/dev/null || echo '未安装')"
    
    echo
    echo "=== 文件检查 ==="
    local files=("$ROOT_DIR/jk.sh" "$ROOT_DIR/web_editor.py" "$ROOT_DIR/zr.py")
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            log_info "✅ $file 存在"
        else
            log_warn "⚠️  $file 不存在"
        fi
    done
    
    echo
    echo "=== 依赖检查 ==="
    if python3 -c "import flask" 2>/dev/null; then
        log_info "✅ Flask 已安装"
    else
        log_warn "⚠️  Flask 未安装"
    fi
    
    echo
    echo "=== 权限检查 ==="
    if [[ -x "$ROOT_DIR/jk.sh" ]]; then
        log_info "✅ jk.sh 有执行权限"
    else
        log_warn "⚠️  jk.sh 无执行权限"
    fi
    
    echo
    echo "=== 网络检查 ==="
    local ip=$(hostname -I | awk '{print $1}')
    if [[ -n "$ip" ]]; then
        log_info "✅ 本机IP: $ip"
    else
        log_warn "⚠️  无法获取本机IP"
    fi
}

# 主函数
main() {
    case "${1:-help}" in
        "install")
            install_service
            ;;
        "uninstall")
            uninstall_service
            ;;
        "start")
            start_service
            ;;
        "stop")
            stop_service
            ;;
        "restart")
            restart_service
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs
            ;;
        "enable")
            enable_autostart
            ;;
        "disable")
            disable_autostart
            ;;
        "check")
            check_system
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# 运行主函数
main "$@" 